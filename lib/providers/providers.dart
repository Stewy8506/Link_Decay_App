import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../data/database.dart';
import '../models/link_status.dart';
import '../services/metadata_service.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';

// ─── Database Provider ─────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─── Settings Provider ─────────────────────────────────────────────────────

final settingsProvider = StreamProvider<AppSetting?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSettings();
});

/// Theme settings provider
final themePaletteProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.themePalette ?? 'warm_stone';
});

/// Swipe left settings provider
final swipeLeftActionProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.swipeLeftAction ?? 'archive';
});

/// Swipe right settings provider
final swipeRightActionProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.swipeRightAction ?? 'read';
});

/// Domain-specific half-life overrides map
final domainHalfLifeOverridesProvider = Provider<Map<String, double>>((ref) {
  final raw = ref.watch(settingsProvider).valueOrNull?.domainHalfLifeOverrides;
  if (raw == null || raw.isEmpty) return const {};
  try {
    final Map<String, dynamic> decoded = jsonDecode(raw);
    return decoded.map((key, val) => MapEntry(key, (val as num).toDouble()));
  } catch (_) {
    return const {};
  }
});

/// Tag-specific half-life overrides map
final tagHalfLifeOverridesProvider = Provider<Map<String, double>>((ref) {
  final raw = ref.watch(settingsProvider).valueOrNull?.tagHalfLifeOverrides;
  if (raw == null || raw.isEmpty) return const {};
  try {
    final Map<String, dynamic> decoded = jsonDecode(raw);
    return decoded.map((key, val) => MapEntry(key, (val as num).toDouble()));
  } catch (_) {
    return const {};
  }
});

/// Helper to get the current base half-life, falling back to default.
final halfLifeDaysProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.halfLifeDays ?? kDefaultHalfLifeDays;
});

/// Helper to get the notification threshold.
final notificationThresholdProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.notificationThreshold ??
      kDefaultNotificationThreshold;
});

/// Whether dark mode is enabled.
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.isDarkMode ?? true;
});

/// Daily reading goal setting provider
final dailyReadingGoalProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.dailyReadingGoal ?? 2;
});

// ─── Collections Providers ───────────────────────────────────────────────

final collectionsProvider = StreamProvider<List<Collection>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCollections();
});

// ─── CustomFilters (Smart Lists) Providers ───────────────────────────────

final customFiltersProvider = StreamProvider<List<CustomFilter>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCustomFilters();
});

// ─── Links Providers ────────────────────────────────────────────────────────

final allLinksProvider = StreamProvider<List<Link>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllLinks();
});

final inboxLinksProvider = StreamProvider<List<Link>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchInboxLinks();
});

final archiveLinksProvider = StreamProvider<List<Link>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchArchiveLinks();
});

// ─── Selection State Providers ─────────────────────────────────────────────

/// Selected link IDs for multi-select actions
final selectedLinkIdsProvider = StateProvider<Set<String>>((ref) => const {});

/// Active filter variables
final inboxSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCollectionIdProvider = StateProvider<String?>((ref) => null);
final selectedFilterIdProvider = StateProvider<String?>((ref) => null);
final inboxSortModeProvider = StateProvider<String>((ref) => 'stalest'); // 'stalest', 'newest', 'read_time', 'domain', 'freshness_desc'

// ─── Smart Lists / Custom Filters Logic ────────────────────────────────────

/// Resolved active query filter parameters
final activeFilterProvider = Provider<CustomFilter?>((ref) {
  final selectedFilterId = ref.watch(selectedFilterIdProvider);
  if (selectedFilterId == null) return null;
  final filters = ref.watch(customFiltersProvider).valueOrNull ?? [];
  return filters.firstWhere((f) => f.id == selectedFilterId);
});

// ─── Sorted/Filtered Inbox Provider ────────────────────────────────────────

final sortedFilteredInboxProvider = Provider<List<Link>>((ref) {
  final allLinks = ref.watch(inboxLinksProvider).valueOrNull ?? [];
  final baseHalfLife = ref.watch(halfLifeDaysProvider);
  final domainOverrides = ref.watch(domainHalfLifeOverridesProvider);
  final tagOverrides = ref.watch(tagHalfLifeOverridesProvider);

  final query = ref.watch(inboxSearchQueryProvider).toLowerCase().trim();
  final collectionId = ref.watch(selectedCollectionIdProvider);
  final customFilter = ref.watch(activeFilterProvider);
  final sortMode = ref.watch(inboxSortModeProvider);

  // Compute freshness scores inline
  final now = DateTime.now();
  final linksWithScore = allLinks.map((link) {
    // Determine the customized half-life for this link
    double halfLife = baseHalfLife;
    if (link.customHalfLifeDays != null) {
      halfLife = link.customHalfLifeDays!;
    } else {
      // Check domain overrides
      if (domainOverrides.containsKey(link.domain.toLowerCase())) {
        halfLife = domainOverrides[link.domain.toLowerCase()]!;
      } else {
        // Check tag overrides (match first matching tag override)
        final tags = link.tags.split(',').map((t) => t.trim().toLowerCase());
        for (final tag in tags) {
          if (tagOverrides.containsKey(tag)) {
            halfLife = tagOverrides[tag]!;
            break;
          }
        }
      }
    }

    final score = computeFreshness(
      createdAt: link.createdAt,
      now: now,
      halfLifeDays: halfLife,
      snoozedUntil: link.snoozedUntil,
    );
    return _LinkWithScore(link, score);
  }).toList();

  // Apply filters
  var filtered = linksWithScore.where((item) {
    final link = item.link;

    // Collection filter
    if (collectionId != null && link.collectionId != collectionId) {
      return false;
    }

    // Text search query
    if (query.isNotEmpty) {
      final titleMatch = link.title?.toLowerCase().contains(query) ?? false;
      final domainMatch = link.domain.toLowerCase().contains(query);
      final tagMatch = link.tags.toLowerCase().contains(query);
      if (!titleMatch && !domainMatch && !tagMatch) return false;
    }

    // Apply Smart Custom Filter if active
    if (customFilter != null) {
      // Freshness range
      if (customFilter.minFreshness != null && item.score < customFilter.minFreshness!) {
        return false;
      }
      if (customFilter.maxFreshness != null && item.score > customFilter.maxFreshness!) {
        return false;
      }

      // Tag filter (at least one matching tag)
      if (customFilter.tags != null && customFilter.tags!.isNotEmpty) {
        final filterTags = customFilter.tags!.split(',').map((t) => t.trim().toLowerCase()).toSet();
        final linkTags = link.tags.split(',').map((t) => t.trim().toLowerCase()).toSet();
        if (linkTags.intersection(filterTags).isEmpty) return false;
      }

      // Collections filter
      if (customFilter.collections != null && customFilter.collections!.isNotEmpty) {
        final filterColls = customFilter.collections!.split(',').map((c) => c.trim()).toSet();
        if (link.collectionId == null || !filterColls.contains(link.collectionId)) return false;
      }

      // Domains filter
      if (customFilter.domains != null && customFilter.domains!.isNotEmpty) {
        final filterDomains = customFilter.domains!.split(',').map((d) => d.trim().toLowerCase()).toSet();
        if (!filterDomains.contains(link.domain.toLowerCase())) return false;
      }

      // Read time boundaries
      final readTime = link.estimatedReadMinutes ?? 1;
      if (customFilter.minReadTime != null && readTime < customFilter.minReadTime!) {
        return false;
      }
      if (customFilter.maxReadTime != null && readTime > customFilter.maxReadTime!) {
        return false;
      }

      // Snooze filter
      final isSnoozed = link.snoozedUntil != null && link.snoozedUntil!.isAfter(now);
      if (customFilter.snoozeFilter == 'exclude_snoozed' && isSnoozed) {
        return false;
      }
      if (customFilter.snoozeFilter == 'only_snoozed' && !isSnoozed) {
        return false;
      }
    }

    return true;
  }).toList();

  // Determine effective sort mode (Custom Filter sort takes precedence if custom filter is active)
  final activeSortMode = (customFilter != null) ? (customFilter.sortField) : sortMode;

  // Apply sorting
  if (activeSortMode == 'stalest' || activeSortMode == 'freshness_asc') {
    filtered.sort((a, b) => a.score.compareTo(b.score));
  } else if (activeSortMode == 'freshness_desc') {
    filtered.sort((a, b) => b.score.compareTo(a.score));
  } else if (activeSortMode == 'newest' || activeSortMode == 'created_desc') {
    filtered.sort((a, b) => b.link.createdAt.compareTo(a.link.createdAt));
  } else if (activeSortMode == 'created_asc') {
    filtered.sort((a, b) => a.link.createdAt.compareTo(b.link.createdAt));
  } else if (activeSortMode == 'read_time' || activeSortMode == 'read_time_asc') {
    filtered.sort((a, b) => (a.link.estimatedReadMinutes ?? 1).compareTo(b.link.estimatedReadMinutes ?? 1));
  } else if (activeSortMode == 'title_asc') {
    filtered.sort((a, b) => (a.link.title ?? '').toLowerCase().compareTo((b.link.title ?? '').toLowerCase()));
  } else if (activeSortMode == 'domain') {
    filtered.sort((a, b) => a.link.domain.compareTo(b.link.domain));
  }

  return filtered.map((item) => item.link).toList();
});

class _LinkWithScore {
  final Link link;
  final double score;
  _LinkWithScore(this.link, this.score);
}

// ─── Link Actions Notifier ─────────────────────────────────────────────────

class LinkActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  AppDatabase get _db => ref.read(databaseProvider);

  /// Save a URL: immediately insert, then fetch rich metadata.
  Future<String> saveLink(String rawUrl, {String? collectionId, String? title}) async {
    final svc = MetadataService.instance;
    final url = svc.normalizeUrl(rawUrl);
    final domain = svc.extractDomain(url);
    final id = _generateId();

    // Domain auto-tagging intelligence
    String autoTag = '';
    final domainLower = domain.toLowerCase();
    if (domainLower.contains('youtube.com') ||
        domainLower.contains('vimeo.com') ||
        domainLower.contains('tiktok.com')) {
      autoTag = 'Video';
    } else if (domainLower.contains('medium.com') ||
        domainLower.contains('substack.com') ||
        domainLower.contains('dev.to') ||
        domainLower.contains('github.blog')) {
      autoTag = 'Article';
    } else if (domainLower.contains('github.com') ||
        domainLower.contains('gitlab.com')) {
      autoTag = 'Code';
    } else if (domainLower.contains('news.ycombinator.com') ||
        domainLower.contains('reddit.com') ||
        domainLower.contains('twitter.com') ||
        domainLower.contains('x.com')) {
      autoTag = 'Social';
    } else if (domainLower.contains('stackoverflow.com')) {
      autoTag = 'Dev';
    }

    await _db.insertLink(
      LinksCompanion.insert(
        id: id,
        url: url,
        domain: domain,
        title: title != null && title.isNotEmpty ? Value(title) : const Value.absent(),
        createdAt: DateTime.now(),
        status: LinkStatus.inbox,
        collectionId: Value(collectionId),
        tags: Value(autoTag),
      ),
    );

    // Fetch metadata asynchronously in the background.
    svc.fetch(url).then((meta) {
      _db.updateMetadata(
        id,
        title: title != null && title.isNotEmpty ? null : meta.title,
        faviconUrl: meta.faviconUrl,
        ogImageUrl: meta.ogImageUrl,
        estimatedReadMinutes: meta.estimatedReadMinutes,
      );
    });

    return id;
  }

  Future<void> markAsRead(String id) async {
    await _db.updateLinkStatus(id, LinkStatus.read);
  }

  Future<void> archive(String id) async {
    await _db.updateLinkStatus(id, LinkStatus.archived);
  }

  Future<void> restoreToInbox(String id) async {
    await _db.updateLinkStatus(id, LinkStatus.inbox);
  }

  Future<void> snooze(String id, Duration duration) async {
    final until = DateTime.now().add(duration);
    await _db.snoozeLink(id, until);
  }

  Future<void> delete(String id) async {
    await _db.deleteLink(id);
  }

  Future<void> updateTags(String id, String tags) async {
    await _db.updateTags(id, tags);
  }

  Future<void> updateNotes(String id, String notes) async {
    await _db.updateNotes(id, notes);
  }

  Future<void> updateTitle(String id, String title) async {
    await (_db.update(_db.links)..where((l) => l.id.equals(id))).write(
      LinksCompanion(title: Value(title)),
    );
  }

  Future<void> updateLinkCollection(String id, String? collectionId) async {
    await _db.updateLinkCollection(id, collectionId);
  }

  Future<void> updateCustomHalfLife(String id, double? customHalfLifeDays) async {
    await _db.updateCustomHalfLife(id, customHalfLifeDays);
  }

  // ── Collection Actions ──────────────────────────────────────────────────

  Future<String> addCollection(String name, String? emoji) async {
    final id = _generateId();
    await _db.insertCollection(
      CollectionsCompanion.insert(
        id: id,
        name: name,
        emoji: Value(emoji),
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  Future<void> updateCollection(String id, String name, String? emoji) async {
    await _db.updateCollection(
      CollectionsCompanion(
        id: Value(id),
        name: Value(name),
        emoji: Value(emoji),
      ),
    );
  }

  Future<void> deleteCollection(String id) async {
    await _db.deleteCollection(id);
  }

  // ── Custom Filter / Smart List Actions ──────────────────────────────────

  Future<void> addCustomFilter({
    required String name,
    required String icon,
    double? minFreshness,
    double? maxFreshness,
    String? tags,
    String? collections,
    String? domains,
    int? minReadTime,
    int? maxReadTime,
    String? snoozeFilter,
    String? sortField,
  }) async {
    final id = _generateId();
    await _db.insertCustomFilter(
      CustomFiltersCompanion.insert(
        id: id,
        name: name,
        icon: Value(icon),
        minFreshness: Value(minFreshness),
        maxFreshness: Value(maxFreshness),
        tags: Value(tags),
        collections: Value(collections),
        domains: Value(domains),
        minReadTime: Value(minReadTime),
        maxReadTime: Value(maxReadTime),
        snoozeFilter: Value(snoozeFilter),
        sortField: Value(sortField ?? 'freshness_asc'),
      ),
    );
  }

  Future<void> deleteCustomFilter(String id) async {
    await _db.deleteCustomFilter(id);
  }

  // ── Highlights ──────────────────────────────────────────────────────────

  Future<void> addHighlight(String linkId, String textContent) async {
    final id = _generateId();
    await _db.insertHighlight(
      LinkHighlightsCompanion.insert(
        id: id,
        linkId: linkId,
        content: textContent,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteHighlight(String id) async {
    await _db.deleteHighlight(id);
  }

  // ── Bulk Actions ────────────────────────────────────────────────────────

  Future<void> bulkArchive(Set<String> ids) async {
    for (final id in ids) {
      await _db.updateLinkStatus(id, LinkStatus.archived);
    }
  }

  Future<void> bulkMarkRead(Set<String> ids) async {
    for (final id in ids) {
      await _db.updateLinkStatus(id, LinkStatus.read);
    }
  }

  Future<void> bulkDelete(Set<String> ids) async {
    for (final id in ids) {
      await _db.deleteLink(id);
    }
  }

  Future<void> bulkMoveToCollection(Set<String> ids, String? collectionId) async {
    for (final id in ids) {
      await _db.updateLinkCollection(id, collectionId);
    }
  }

  Future<void> bulkAddTag(Set<String> ids, String tag) async {
    for (final id in ids) {
      final link = await (_db.select(_db.links)..where((l) => l.id.equals(id))).getSingleOrNull();
      if (link == null) continue;
      final existingTags = link.tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      if (!existingTags.contains(tag)) {
        existingTags.add(tag);
        await _db.updateTags(id, existingTags.join(', '));
      }
    }
  }

  // ── Settings ──────────────────────────────────────────────────────────

  Future<void> updateSettings({
    double? halfLifeDays,
    double? notificationThreshold,
    bool? notificationsEnabled,
    bool? isDarkMode,
    String? themePalette,
    String? swipeLeftAction,
    String? swipeRightAction,
    String? domainHalfLifeOverrides,
    String? tagHalfLifeOverrides,
    int? dailyReadingGoal,
  }) async {
    final current = await _db.getSettings();
    await _db.upsertSettings(
      AppSettingsCompanion.insert(
        id: const Value(1),
        halfLifeDays: Value(halfLifeDays ?? current?.halfLifeDays ?? kDefaultHalfLifeDays),
        notificationThreshold: Value(notificationThreshold ?? current?.notificationThreshold ?? kDefaultNotificationThreshold),
        notificationsEnabled: Value(notificationsEnabled ?? current?.notificationsEnabled ?? kDefaultNotificationsEnabled),
        isDarkMode: Value(isDarkMode ?? current?.isDarkMode ?? true),
        themePalette: Value(themePalette ?? current?.themePalette ?? 'warm_stone'),
        swipeLeftAction: Value(swipeLeftAction ?? current?.swipeLeftAction ?? 'archive'),
        swipeRightAction: Value(swipeRightAction ?? current?.swipeRightAction ?? 'read'),
        domainHalfLifeOverrides: Value(domainHalfLifeOverrides ?? current?.domainHalfLifeOverrides),
        tagHalfLifeOverrides: Value(tagHalfLifeOverrides ?? current?.tagHalfLifeOverrides),
        dailyReadingGoal: Value(dailyReadingGoal ?? current?.dailyReadingGoal ?? 2),
      ),
    );
  }

  String _generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = ts % 999999;
    return '${ts}_$rand';
  }
}

final linkActionsProvider = NotifierProvider<LinkActionsNotifier, void>(
  LinkActionsNotifier.new,
);

// ─── Archive Search/Filter ─────────────────────────────────────────────────

final archiveSearchQueryProvider = StateProvider<String>((ref) => '');
final archiveStatusFilterProvider = StateProvider<LinkStatus?>((ref) => null);
final archiveTagFilterProvider = StateProvider<String?>((ref) => null);

final filteredArchiveLinksProvider = Provider<List<Link>>((ref) {
  final allLinks = ref.watch(archiveLinksProvider).valueOrNull ?? [];
  final query = ref.watch(archiveSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(archiveStatusFilterProvider);
  final tagFilter = ref.watch(archiveTagFilterProvider);

  return allLinks.where((link) {
    if (statusFilter != null && link.status != statusFilter) return false;
    if (tagFilter != null && tagFilter.isNotEmpty) {
      final tags = link.tags.split(',').map((t) => t.trim().toLowerCase());
      if (!tags.contains(tagFilter.toLowerCase())) return false;
    }
    if (query.isNotEmpty) {
      final titleMatch = link.title?.toLowerCase().contains(query) ?? false;
      final domainMatch = link.domain.toLowerCase().contains(query);
      final tagMatch = link.tags.toLowerCase().contains(query);
      if (!titleMatch && !domainMatch && !tagMatch) return false;
    }
    return true;
  }).toList();
});

/// All unique tags across all links (for filter chips).
final allTagsProvider = Provider<List<String>>((ref) {
  final inbox = ref.watch(inboxLinksProvider).valueOrNull ?? [];
  final archive = ref.watch(archiveLinksProvider).valueOrNull ?? [];
  final all = [...inbox, ...archive];
  final tagSet = <String>{};
  for (final link in all) {
    final tags = link.tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty);
    tagSet.addAll(tags);
  }
  return tagSet.toList()..sort();
});

class _LinkWithScoreForSync {
  final Link link;
  final double score;
  _LinkWithScoreForSync(this.link, this.score);
}

final widgetSyncProvider = Provider<void>((ref) {
  final inboxLinks = ref.watch(inboxLinksProvider).valueOrNull ?? [];
  if (inboxLinks.isEmpty) {
    _syncTopStaleLinks([]);
    return;
  }
  final baseHalfLife = ref.watch(halfLifeDaysProvider);
  final domainOverrides = ref.watch(domainHalfLifeOverridesProvider);
  final tagOverrides = ref.watch(tagHalfLifeOverridesProvider);
  final now = DateTime.now();

  final scored = inboxLinks.map((link) {
    double halfLife = baseHalfLife;
    if (link.customHalfLifeDays != null) {
      halfLife = link.customHalfLifeDays!;
    } else {
      if (domainOverrides.containsKey(link.domain.toLowerCase())) {
        halfLife = domainOverrides[link.domain.toLowerCase()]!;
      } else {
        final tags = link.tags.split(',').map((t) => t.trim().toLowerCase());
        for (final tag in tags) {
          if (tagOverrides.containsKey(tag)) {
            halfLife = tagOverrides[tag]!;
            break;
          }
        }
      }
    }
    final score = computeFreshness(
      createdAt: link.createdAt,
      now: now,
      halfLifeDays: halfLife,
      snoozedUntil: link.snoozedUntil,
    );
    return _LinkWithScoreForSync(link, score);
  }).toList();

  scored.sort((a, b) => a.score.compareTo(b.score));
  final top3 = scored.take(3).toList();
  _syncTopStaleLinks(top3);
});

Future<void> _syncTopStaleLinks(List<_LinkWithScoreForSync> scoredItems) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final data = scoredItems.map((item) => {
      'id': item.link.id,
      'title': item.link.title ?? item.link.domain,
      'url': item.link.url,
      'domain': item.link.domain,
      'createdAt': item.link.createdAt.toIso8601String(),
      'freshnessScore': item.score,
    }).toList();
    await prefs.setString('widget_stale_links', jsonEncode(data));
  } catch (_) {}
}

