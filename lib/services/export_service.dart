import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../models/link_status.dart';
import '../utils/constants.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class ExportService {
  ExportService._internal();
  static final ExportService instance = ExportService._internal();

  /// Compiles all database data into a single JSON Map
  Future<Map<String, dynamic>> _compileBackupData() async {
    final fs = FirestoreService.instance;
    final links = await fs.getAllLinksFuture();
    final collections = await fs.getCollectionsFuture();
    final customFilters = await fs.getFiltersFuture();
    final settings = await fs.getSettings();

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
        'dailyReadingGoal': settings.dailyReadingGoal,
        'snoozePresets': settings.snoozePresets,
        'fontFamily': settings.fontFamily,
        'customAccentColor': settings.customAccentColor,
        'customBgColor': settings.customBgColor,
        'decayCurveType': settings.decayCurveType,
      },
    };
  }

  /// Exports data to JSON file and triggers native sharing share sheet
  Future<void> shareJsonExport() async {
    final data = await _compileBackupData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/linkshelf_backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'LinkShelf Backup');
  }

  /// Exports data as Netscape HTML Bookmarks
  Future<void> shareHtmlExport() async {
    final fs = FirestoreService.instance;
    final links = await fs.getAllLinksFuture();
    
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
  Future<int> importFromJson(String jsonContent, {required bool merge}) async {
    final Map<String, dynamic> data = jsonDecode(jsonContent);
    int importCount = 0;
    final fs = FirestoreService.instance;

    // Save current state for rollback on error
    final backupLinks = await fs.getAllLinksFuture();
    final backupColls = await fs.getCollectionsFuture();
    final backupFilters = await fs.getFiltersFuture();
    final backupSettings = await fs.getSettings();

    try {
      if (!merge) {
        // Clear current data
        final links = await fs.getAllLinksFuture();
        for (final l in links) {
          await fs.deleteLink(l.id);
        }
        final colls = await fs.getCollectionsFuture();
        for (final c in colls) {
          await fs.deleteCollection(c.id);
        }
        final filters = await fs.getFiltersFuture();
        for (final f in filters) {
          await fs.deleteCustomFilter(f.id);
        }
      }

      // Import Collections
      if (data.containsKey('collections')) {
        final List<dynamic> colls = data['collections'];
        for (final c in colls) {
          await fs.insertCollection(
            Collection(
              id: c['id'],
              name: c['name'],
              emoji: c['emoji'],
              createdAt: DateTime.tryParse(c['createdAt']) ?? DateTime.now(),
              sortOrder: c['sortOrder'] ?? 0,
            ),
          );
        }
      }

      // Import Custom Filters
      if (data.containsKey('customFilters')) {
        final List<dynamic> filts = data['customFilters'];
        for (final f in filts) {
          await fs.insertCustomFilter(
            CustomFilter(
              id: f['id'],
              name: f['name'],
              icon: f['icon'] ?? 'list',
              minFreshness: f['minFreshness']?.toDouble(),
              maxFreshness: f['maxFreshness']?.toDouble(),
              tags: f['tags'],
              collections: f['collections'],
              domains: f['domains'],
              minReadTime: f['minReadTime'],
              maxReadTime: f['maxReadTime'],
              snoozeFilter: f['snoozeFilter'],
              sortField: f['sortField'] ?? 'freshness_asc',
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

          // Force format validation so we fail early for malformed inputs
          final createdAtStr = l['createdAt'];
          DateTime? parsedCreated;
          if (createdAtStr != null) {
            parsedCreated = DateTime.tryParse(createdAtStr);
            if (parsedCreated == null && createdAtStr is String && createdAtStr.isNotEmpty) {
              throw FormatException('Invalid date format: $createdAtStr');
            }
          }

          final snoozedUntilStr = l['snoozedUntil'];
          DateTime? parsedSnoozed;
          if (snoozedUntilStr != null) {
            parsedSnoozed = DateTime.tryParse(snoozedUntilStr);
            if (parsedSnoozed == null && snoozedUntilStr is String && snoozedUntilStr.isNotEmpty) {
              throw FormatException('Invalid date format: $snoozedUntilStr');
            }
          }

          await fs.insertLink(
            Link(
              id: l['id'],
              url: l['url'],
              title: l['title'],
              domain: l['domain'],
              faviconUrl: l['faviconUrl'],
              createdAt: parsedCreated ?? DateTime.now(),
              snoozedUntil: parsedSnoozed,
              status: status,
              tags: l['tags'] ?? '',
              snoozedSeconds: l['snoozedSeconds'] ?? 0,
              collectionId: l['collectionId'],
              notes: l['notes'],
              ogImageUrl: l['ogImageUrl'],
              estimatedReadMinutes: l['estimatedReadMinutes'],
              customHalfLifeDays: l['customHalfLifeDays']?.toDouble(),
              isDead: l['isDead'] ?? false,
            ),
          );
          importCount++;
        }
      }

      // Import Settings (Optional override)
      if (data.containsKey('settings') && data['settings'] != null) {
        final s = data['settings'];
        await fs.upsertSettings(
          AppSetting(
            halfLifeDays: (s['halfLifeDays'] ?? kDefaultHalfLifeDays).toDouble(),
            notificationThreshold: (s['notificationThreshold'] ?? kDefaultNotificationThreshold).toDouble(),
            notificationsEnabled: s['notificationsEnabled'] ?? kDefaultNotificationsEnabled,
            isDarkMode: s['isDarkMode'] ?? true,
            themePalette: s['themePalette'] ?? 'warm_stone',
            swipeLeftAction: s['swipeLeftAction'] ?? 'archive',
            swipeRightAction: s['swipeRightAction'] ?? 'read',
            domainHalfLifeOverrides: s['domainHalfLifeOverrides'],
            tagHalfLifeOverrides: s['tagHalfLifeOverrides'],
            dailyReadingGoal: s['dailyReadingGoal'] ?? 2,
            snoozePresets: s['snoozePresets'] ?? '[1, 3, 7]',
            fontFamily: s['fontFamily'] ?? 'inter',
            customAccentColor: s['customAccentColor'],
            customBgColor: s['customBgColor'],
            decayCurveType: s['decayCurveType'] ?? 'exponential',
          ),
        );

        // Reschedule notifications outside transaction if settings were imported
        try {
          final enabled = s['notificationsEnabled'] ?? kDefaultNotificationsEnabled;
          if (enabled) {
            await NotificationService.instance.scheduleDailyCheck(
              halfLifeDays: (s['halfLifeDays'] ?? kDefaultHalfLifeDays).toDouble(),
              threshold: (s['notificationThreshold'] ?? kDefaultNotificationThreshold).toDouble(),
              decayCurveType: s['decayCurveType'] ?? 'exponential',
            );
            await NotificationService.instance.scheduleWeeklyDigest(
              halfLifeDays: (s['halfLifeDays'] ?? kDefaultHalfLifeDays).toDouble(),
              decayCurveType: s['decayCurveType'] ?? 'exponential',
            );
          } else {
            await NotificationService.instance.cancelAll();
          }
        } catch (_) {}
      }
    } catch (e) {
      // Rollback current additions/updates
      final linksToClear = await fs.getAllLinksFuture();
      for (final l in linksToClear) {
        await fs.deleteLink(l.id);
      }
      final collsToClear = await fs.getCollectionsFuture();
      for (final c in collsToClear) {
        await fs.deleteCollection(c.id);
      }
      final filtersToClear = await fs.getFiltersFuture();
      for (final f in filtersToClear) {
        await fs.deleteCustomFilter(f.id);
      }

      // Restore backup state
      for (final l in backupLinks) {
        await fs.insertLink(l);
      }
      for (final c in backupColls) {
        await fs.insertCollection(c);
      }
      for (final f in backupFilters) {
        await fs.insertCustomFilter(f);
      }
      if (backupSettings != null) {
        await fs.upsertSettings(backupSettings);
      }
      rethrow;
    }

    return importCount;
  }

  /// Simple Netscape HTML Bookmarks parser
  Future<int> importFromHtml(String htmlContent) async {
    final hrefRegex = RegExp(r'HREF="([^"]+)"', caseSensitive: false);
    final titleRegex = RegExp(r'<A[^>]*>([^<]+)</A>', caseSensitive: false);
    final tagsRegex = RegExp(r'TAGS="([^"]*)"', caseSensitive: false);

    final lines = htmlContent.split('\n');
    int importCount = 0;
    final fs = FirestoreService.instance;

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

      await fs.insertLink(
        Link(
          id: id,
          url: url,
          domain: domain,
          title: title,
          faviconUrl: 'https://www.google.com/s2/favicons?domain=$domain&sz=64',
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
          tags: tags,
          snoozedSeconds: 0,
          isDead: false,
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

  /// Exports a collection's links as a beautiful, self-contained HTML page
  Future<void> shareCollectionAsHtml(Collection collection, List<Link> links) async {
    final buffer = StringBuffer()
      ..writeln('<!DOCTYPE html>')
      ..writeln('<html lang="en">')
      ..writeln('<head>')
      ..writeln('  <meta charset="UTF-8">')
      ..writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">')
      ..writeln('  <title>${collection.name} - Curated List</title>')
      ..writeln('  <link rel="preconnect" href="https://fonts.googleapis.com">')
      ..writeln('  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>')
      ..writeln('  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">')
      ..writeln('  <style>')
      ..writeln("    body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; background-color: #FAF9F6; color: #1C1917; margin: 0; padding: 40px 20px; line-height: 1.5; }")
      ..writeln('    .container { max-width: 600px; margin: 0 auto; }')
      ..writeln('    .header { margin-bottom: 40px; }')
      ..writeln('    .folder-emoji { font-size: 48px; margin-bottom: 8px; }')
      ..writeln('    h1 { font-size: 28px; font-weight: 700; margin: 0 0 8px 0; letter-spacing: -0.5px; }')
      ..writeln('    .meta { font-size: 14px; color: #78716C; }')
      ..writeln('    .links-list { list-style: none; padding: 0; margin: 0; }')
      ..writeln('    .link-item { background: #FFFFFF; border: 1px solid #E7E5E4; border-radius: 12px; padding: 20px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); transition: transform 0.2s ease, box-shadow 0.2s ease; }')
      ..writeln('    .link-item:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.05); }')
      ..writeln('    .link-title { font-size: 16px; font-weight: 600; margin: 0 0 6px 0; line-height: 1.4; }')
      ..writeln('    .link-title a { color: #1C1917; text-decoration: none; }')
      ..writeln('    .link-title a:hover { text-decoration: underline; }')
      ..writeln('    .link-meta { font-size: 12px; color: #78716C; display: flex; flex-wrap: wrap; align-items: center; gap: 8px; }')
      ..writeln('    .link-domain { font-weight: 500; }')
      ..writeln('    .bullet { color: #D6D3D1; }')
      ..writeln('    .tag { background: #F5F5F4; color: #57534E; padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 500; }')
      ..writeln('    .footer { margin-top: 60px; text-align: center; font-size: 12px; color: #A8A29E; }')
      ..writeln('    .footer a { color: #78716C; text-decoration: none; }')
      ..writeln('  </style>')
      ..writeln('</head>')
      ..writeln('<body>')
      ..writeln('  <div class="container">')
      ..writeln('    <div class="header">')
      ..writeln('      <div class="folder-emoji">${collection.emoji ?? "📁"}</div>')
      ..writeln('      <h1>${collection.name}</h1>')
      ..writeln('      <div class="meta">${links.length} links &bull; Curated via LinkShelf</div>')
      ..writeln('    </div>')
      ..writeln('    <ul class="links-list">');

    for (final link in links) {
      final title = link.title ?? link.domain;
      buffer.writeln('      <li class="link-item">');
      buffer.writeln('        <h2 class="link-title"><a href="${link.url}" target="_blank" rel="noopener noreferrer">$title</a></h2>');
      buffer.writeln('        <div class="link-meta">');
      buffer.writeln('          <span class="link-domain">${link.domain}</span>');
      if (link.estimatedReadMinutes != null) {
        buffer.writeln('          <span class="bullet">&bull;</span>');
        buffer.writeln('          <span>${link.estimatedReadMinutes} min read</span>');
      }
      if (link.tags.isNotEmpty) {
        final tagList = link.tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
        for (final tag in tagList) {
          buffer.writeln('          <span class="tag">$tag</span>');
        }
      }
      buffer.writeln('        </div>');
      buffer.writeln('      </li>');
    }

    buffer
      ..writeln('    </ul>')
      ..writeln('    <div class="footer">')
      ..writeln('      Generated with <a href="https://github.com/Stewy8506/Link_Decay_App" target="_blank" rel="noopener noreferrer">LinkShelf</a>')
      ..writeln('    </div>')
      ..writeln('  </div>')
      ..writeln('</body>')
      ..writeln('</html>');

    final dir = await getTemporaryDirectory();
    final safeName = collection.name.replaceAll(RegExp(r'[^\w\s\-]'), '').trim().replaceAll(' ', '_');
    final file = File('${dir.path}/${safeName}_read_list.html');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: '${collection.emoji ?? "📁"} ${collection.name} Read List');
  }
}
