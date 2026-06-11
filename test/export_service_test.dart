import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_decay_app/data/database.dart';
import 'package:link_decay_app/models/link_status.dart';
import 'package:link_decay_app/services/export_service.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('ExportService Import & Export Tests', () {

    test('JSON Import: Overwrite mode purges database first', () async {
      final exporter = ExportService.instance;

      // 1. Insert collection and link
      await db.into(db.collections).insert(
        CollectionsCompanion.insert(
          id: 'col_local',
          name: 'Local Collection',
          createdAt: DateTime.now(),
        ),
      );
      await db.into(db.links).insert(
        LinksCompanion.insert(
          id: 'link_local',
          url: 'https://flutter.dev',
          domain: 'flutter.dev',
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
        ),
      );

      // Verify insertion
      final beforeLinks = await db.select(db.links).get();
      expect(beforeLinks.length, 1);

      // 2. Prepare JSON backup
      final backupJson = {
        'version': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'collections': [
          {
            'id': 'col_backup',
            'name': 'Backup Collection',
            'createdAt': DateTime.now().toIso8601String(),
            'sortOrder': 0,
          }
        ],
        'links': [
          {
            'id': 'link_backup',
            'url': 'https://dart.dev',
            'domain': 'dart.dev',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'inbox',
          }
        ]
      };

      // 3. Run import in overwrite mode (merge: false)
      final count = await exporter.importFromJson(db, jsonEncode(backupJson), merge: false);
      expect(count, 1);

      // 4. Verify local data is purged and replaced by backup data
      final afterLinks = await db.select(db.links).get();
      expect(afterLinks.length, 1);
      expect(afterLinks.first.id, 'link_backup');
      expect(afterLinks.first.domain, 'dart.dev');

      final afterColls = await db.select(db.collections).get();
      expect(afterColls.length, 1);
      expect(afterColls.first.id, 'col_backup');
    });

    test('JSON Import: Merge mode keeps local database items', () async {
      final exporter = ExportService.instance;

      // 1. Insert local item
      await db.into(db.links).insert(
        LinksCompanion.insert(
          id: 'link_local',
          url: 'https://flutter.dev',
          domain: 'flutter.dev',
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
        ),
      );

      // 2. Prepare JSON backup with overlapping and non-overlapping items
      final backupJson = {
        'version': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'links': [
          {
            'id': 'link_backup',
            'url': 'https://dart.dev',
            'domain': 'dart.dev',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'inbox',
          }
        ]
      };

      // 3. Run import in merge mode (merge: true)
      final count = await exporter.importFromJson(db, jsonEncode(backupJson), merge: true);
      expect(count, 1);

      // 4. Verify both items exist in the database
      final afterLinks = await db.select(db.links).get();
      expect(afterLinks.length, 2);

      final ids = afterLinks.map((l) => l.id).toSet();
      expect(ids.contains('link_local'), true);
      expect(ids.contains('link_backup'), true);
    });

    test('HTML Bookmarks Ingestion: Regex extracts HREF and title correctly', () async {
      final exporter = ExportService.instance;

      final bookmarksHtml = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><A HREF="https://news.ycombinator.com" ADD_DATE="1717000000" TAGS="dev, news">Hacker News</A>
    <DT><A HREF="https://github.com" ADD_DATE="1717000000" TAGS="code">GitHub</A>
</DL><p>
''';

      final count = await exporter.importFromHtml(db, bookmarksHtml);
      expect(count, 2);

      final imported = await db.select(db.links).get();
      expect(imported.length, 2);

      final hn = imported.firstWhere((l) => l.domain == 'news.ycombinator.com');
      expect(hn.url, 'https://news.ycombinator.com');
      expect(hn.title, 'Hacker News');
      expect(hn.tags, 'dev, news');

      final gh = imported.firstWhere((l) => l.domain == 'github.com');
      expect(gh.url, 'https://github.com');
      expect(gh.title, 'GitHub');
      expect(gh.tags, 'code');
    });

    test('JSON Import: Malformed JSON rolls back cleanly and doesn\'t save partial data', () async {
      final exporter = ExportService.instance;

      // 1. Insert local link first
      await db.into(db.links).insert(
        LinksCompanion.insert(
          id: 'link_local',
          url: 'https://flutter.dev',
          domain: 'flutter.dev',
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
        ),
      );

      // 2. Prepare malformed JSON (contains non-parsable date format for collections, which throws in transaction)
      final malformedBackupJson = {
        'version': 2,
        'collections': [
          {
            'id': 'col_success',
            'name': 'Success Coll',
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
        'links': [
          {
            'id': 'link_success',
            'url': 'https://success.com',
            'domain': 'success.com',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'inbox',
          },
          {
            'id': 'link_fail',
            'url': 'https://fail.com',
            'domain': 'fail.com',
            'createdAt': 'this-is-not-a-valid-date-format', // Will crash DateTime.parse()
            'status': 'inbox',
          }
        ]
      };

      // 3. Try to run import in overwrite mode. This should throw format exception.
      expect(
        () async => await exporter.importFromJson(db, jsonEncode(malformedBackupJson), merge: false),
        throwsA(isA<FormatException>()),
      );

      // 4. Verify transaction rolled back: original 'link_local' was deleted because of overwrite mode initially,
      // but because the transaction rolled back, the delete was undone and the database is exactly as it was!
      final links = await db.select(db.links).get();
      expect(links.length, 1);
      expect(links.first.id, 'link_local');

      // Verify no collections were saved either
      final colls = await db.select(db.collections).get();
      expect(colls.isEmpty, true);
    });
  });
}
