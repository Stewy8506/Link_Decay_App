import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/link_status.dart';
import '../services/metadata_service.dart';
import '../utils/constants.dart';

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

/// A helper to get the current half-life, falling back to default.
final halfLifeDaysProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.halfLifeDays ??
      kDefaultHalfLifeDays;
});

/// A helper to get the notification threshold.
final notificationThresholdProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.notificationThreshold ??
      kDefaultNotificationThreshold;
});

/// Whether dark mode is enabled.
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.isDarkMode ?? true;
});

// ─── Links Providers ────────────────────────────────────────────────────────

final inboxLinksProvider = StreamProvider<List<Link>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchInboxLinks();
});

final archiveLinksProvider = StreamProvider<List<Link>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchArchiveLinks();
});

// ─── Link Actions Notifier ─────────────────────────────────────────────────

class LinkActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  AppDatabase get _db => ref.read(databaseProvider);

  /// Save a URL: immediately insert with domain/placeholder, then fetch metadata.
  Future<String> saveLink(String rawUrl) async {
    final svc = MetadataService.instance;
    final url = svc.normalizeUrl(rawUrl);
    final domain = svc.extractDomain(url);
    final id = _generateId();

    await _db.insertLink(
      LinksCompanion.insert(
        id: id,
        url: url,
        domain: domain,
        createdAt: DateTime.now(),
        status: LinkStatus.inbox,
      ),
    );

    // Fetch metadata asynchronously in the background.
    svc.fetch(url).then((meta) {
      _db.updateMetadata(id, title: meta.title, faviconUrl: meta.faviconUrl);
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

  Future<void> updateSettings({
    double? halfLifeDays,
    double? notificationThreshold,
    bool? notificationsEnabled,
    bool? isDarkMode,
  }) async {
    final current = await _db.getSettings();
    await _db.upsertSettings(
      AppSettingsCompanion.insert(
        id: const Value(1),
        halfLifeDays: Value(
          halfLifeDays ?? current?.halfLifeDays ?? kDefaultHalfLifeDays,
        ),
        notificationThreshold: Value(
          notificationThreshold ??
              current?.notificationThreshold ??
              kDefaultNotificationThreshold,
        ),
        notificationsEnabled: Value(
          notificationsEnabled ??
              current?.notificationsEnabled ??
              kDefaultNotificationsEnabled,
        ),
        isDarkMode: Value(isDarkMode ?? current?.isDarkMode ?? true),
      ),
    );
  }

  String _generateId() {
    // Simple timestamp + random suffix for unique IDs without uuid package overhead.
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
final archiveStatusFilterProvider = StateProvider<LinkStatus?>(
  (ref) => null,
); // null = all
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
