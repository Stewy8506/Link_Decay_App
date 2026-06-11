import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../models/link_status.dart';
import '../utils/constants.dart';

class ExportService {
  ExportService._internal();
  static final ExportService instance = ExportService._internal();

  /// Compiles all database data into a single JSON Map
  Future<Map<String, dynamic>> _compileBackupData(AppDatabase db) async {
    final links = await db.select(db.links).get();
    final collections = await db.select(db.collections).get();
    final customFilters = await db.select(db.customFilters).get();
    final settings = await db.getSettings();

    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'links': links.map((l) => {
        'id': l.id,
        'url': l.url,
        'title': l.title,
        'domain': l.domain,
        'faviconUrl': l.faviconUrl,
        'createdAt': l.createdAt.toIso8601String(),
        'snoozedUntil': l.snoozedUntil?.toIso8601String(),
        'status': l.status.name,
        'tags': l.tags,
        'snoozedSeconds': l.snoozedSeconds,
        'collectionId': l.collectionId,
        'notes': l.notes,
        'ogImageUrl': l.ogImageUrl,
        'estimatedReadMinutes': l.estimatedReadMinutes,
        'customHalfLifeDays': l.customHalfLifeDays,
      }).toList(),
      'collections': collections.map((c) => {
        'id': c.id,
        'name': c.name,
        'emoji': c.emoji,
        'createdAt': c.createdAt.toIso8601String(),
        'sortOrder': c.sortOrder,
      }).toList(),
      'customFilters': customFilters.map((f) => {
        'id': f.id,
        'name': f.name,
        'icon': f.icon,
        'minFreshness': f.minFreshness,
        'maxFreshness': f.maxFreshness,
        'tags': f.tags,
        'collections': f.collections,
        'domains': f.domains,
        'minReadTime': f.minReadTime,
        'maxReadTime': f.maxReadTime,
        'snoozeFilter': f.snoozeFilter,
        'sortField': f.sortField,
      }).toList(),
      'settings': settings == null ? null : {
        'halfLifeDays': settings.halfLifeDays,
        'notificationThreshold': settings.notificationThreshold,
        'notificationsEnabled': settings.notificationsEnabled,
        'isDarkMode': settings.isDarkMode,
        'themePalette': settings.themePalette,
        'swipeLeftAction': settings.swipeLeftAction,
        'swipeRightAction': settings.swipeRightAction,
        'domainHalfLifeOverrides': settings.domainHalfLifeOverrides,
        'tagHalfLifeOverrides': settings.tagHalfLifeOverrides,
      },
    };
  }

  /// Exports data to JSON file and triggers native sharing share sheet
  Future<void> shareJsonExport(AppDatabase db) async {
    final data = await _compileBackupData(db);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/linkshelf_backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'LinkShelf Backup');
  }

  /// Exports data as Netscape HTML Bookmarks
  Future<void> shareHtmlExport(AppDatabase db) async {
    final links = await db.select(db.links).get();
    
    final buffer = StringBuffer()
      ..writeln('<!DOCTYPE NETSCAPE-Bookmark-file-1>')
      ..writeln('<!-- This is an automatically generated file.')
      ..writeln('     It will be read and imported by browser bookmark tools. -->')
      ..writeln('<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">')
      ..writeln('<TITLE>Bookmarks</TITLE>')
      ..writeln('<H1>LinkShelf Bookmarks</H1>')
      ..writeln('<DL><p>');

    for (final link in links) {
      final addedUnix = (link.createdAt.millisecondsSinceEpoch / 1000).round();
      final title = link.title ?? link.domain;
      buffer.writeln('    <DT><A HREF="${link.url}" ADD_DATE="$addedUnix" TAGS="${link.tags}">$title</A>');
    }

    buffer.writeln('</DL><p>');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/linkshelf_bookmarks.html');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'LinkShelf Bookmarks');
  }

  /// Imports from JSON string
  Future<int> importFromJson(AppDatabase db, String jsonContent, {required bool merge}) async {
    final Map<String, dynamic> data = jsonDecode(jsonContent);
    int importCount = 0;

    if (!merge) {
      // Clear current data
      await db.delete(db.links).go();
      await db.delete(db.collections).go();
      await db.delete(db.customFilters).go();
    }

    // Import Collections
    if (data.containsKey('collections')) {
      final List<dynamic> colls = data['collections'];
      for (final c in colls) {
        await db.into(db.collections).insertOnConflictUpdate(
          CollectionsCompanion.insert(
            id: c['id'],
            name: c['name'],
            emoji: Value(c['emoji']),
            createdAt: DateTime.parse(c['createdAt']),
            sortOrder: Value(c['sortOrder'] ?? 0),
          ),
        );
      }
    }

    // Import Custom Filters
    if (data.containsKey('customFilters')) {
      final List<dynamic> filts = data['customFilters'];
      for (final f in filts) {
        await db.into(db.customFilters).insertOnConflictUpdate(
          CustomFiltersCompanion.insert(
            id: f['id'],
            name: f['name'],
            icon: Value(f['icon'] ?? 'list'),
            minFreshness: Value(f['minFreshness']),
            maxFreshness: Value(f['maxFreshness']),
            tags: Value(f['tags']),
            collections: Value(f['collections']),
            domains: Value(f['domains']),
            minReadTime: Value(f['minReadTime']),
            maxReadTime: Value(f['maxReadTime']),
            snoozeFilter: Value(f['snoozeFilter']),
            sortField: Value(f['sortField'] ?? 'freshness_asc'),
          ),
        );
      }
    }

    // Import Links
    if (data.containsKey('links')) {
      final List<dynamic> lnks = data['links'];
      for (final l in lnks) {
        final status = LinkStatus.values.firstWhere(
          (s) => s.name == l['status'],
          orElse: () => LinkStatus.inbox,
        );

        await db.into(db.links).insertOnConflictUpdate(
          LinksCompanion.insert(
            id: l['id'],
            url: l['url'],
            title: Value(l['title']),
            domain: l['domain'],
            faviconUrl: Value(l['faviconUrl']),
            createdAt: DateTime.parse(l['createdAt']),
            snoozedUntil: Value(l['snoozedUntil'] != null ? DateTime.parse(l['snoozedUntil']) : null),
            status: status,
            tags: Value(l['tags'] ?? ''),
            snoozedSeconds: Value(l['snoozedSeconds'] ?? 0),
            collectionId: Value(l['collectionId']),
            notes: Value(l['notes']),
            ogImageUrl: Value(l['ogImageUrl']),
            estimatedReadMinutes: Value(l['estimatedReadMinutes']),
            customHalfLifeDays: Value(l['customHalfLifeDays']),
          ),
        );
        importCount++;
      }
    }

    // Import Settings (Optional override)
    if (data.containsKey('settings') && data['settings'] != null) {
      final s = data['settings'];
      await db.upsertSettings(
        AppSettingsCompanion.insert(
          id: const Value(1),
          halfLifeDays: Value(s['halfLifeDays'] ?? kDefaultHalfLifeDays),
          notificationThreshold: Value(s['notificationThreshold'] ?? kDefaultNotificationThreshold),
          notificationsEnabled: Value(s['notificationsEnabled'] ?? kDefaultNotificationsEnabled),
          isDarkMode: Value(s['isDarkMode'] ?? true),
          themePalette: Value(s['themePalette'] ?? 'warm_stone'),
          swipeLeftAction: Value(s['swipeLeftAction'] ?? 'archive'),
          swipeRightAction: Value(s['swipeRightAction'] ?? 'read'),
          domainHalfLifeOverrides: Value(s['domainHalfLifeOverrides']),
          tagHalfLifeOverrides: Value(s['tagHalfLifeOverrides']),
        ),
      );
    }

    return importCount;
  }

  /// Simple Netscape HTML Bookmarks parser
  Future<int> importFromHtml(AppDatabase db, String htmlContent) async {
    final hrefRegex = RegExp(r'HREF="([^"]+)"', caseSensitive: false);
    final titleRegex = RegExp(r'<A[^>]*>([^<]+)</A>', caseSensitive: false);
    final tagsRegex = RegExp(r'TAGS="([^"]*)"', caseSensitive: false);

    final lines = htmlContent.split('\n');
    int importCount = 0;

    for (final line in lines) {
      final hrefMatch = hrefRegex.firstMatch(line);
      if (hrefMatch == null) continue;

      final url = hrefMatch.group(1)!;
      final titleMatch = titleRegex.firstMatch(line);
      final title = titleMatch?.group(1);
      
      final tagsMatch = tagsRegex.firstMatch(line);
      final tags = tagsMatch != null ? tagsMatch.group(1) ?? '' : '';

      final domain = _extractDomain(url);
      final id = '${DateTime.now().millisecondsSinceEpoch}_${importCount}_html';

      await db.into(db.links).insert(
        LinksCompanion.insert(
          id: id,
          url: url,
          domain: domain,
          title: Value(title),
          faviconUrl: Value('https://www.google.com/s2/favicons?domain=$domain&sz=64'),
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
          tags: Value(tags),
        ),
      );
      importCount++;
    }

    return importCount;
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}
