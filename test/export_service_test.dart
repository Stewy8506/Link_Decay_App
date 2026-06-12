import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_decay_app/models/models.dart';
import 'package:link_decay_app/models/link_status.dart';
import 'package:link_decay_app/services/export_service.dart';
import 'package:link_decay_app/services/firestore_service.dart';

class MockFirestoreService implements FirestoreService {
  Map<String, Link> links = {};
  Map<String, Collection> collections = {};
  Map<String, CustomFilter> customFilters = {};
  AppSetting? settings;

  @override
  Future<List<Link>> getAllLinksFuture() async => links.values.toList();

  @override
  Future<List<Collection>> getCollectionsFuture() async {
    final list = collections.values.toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  @override
  Future<List<CustomFilter>> getFiltersFuture() async =>
      customFilters.values.toList();

  @override
  Future<AppSetting?> getSettings() async => settings;

  @override
  Future<void> deleteLink(String id) async => links.remove(id);

  @override
  Future<void> deleteCollection(String id) async => collections.remove(id);

  @override
  Future<void> deleteCustomFilter(String id) async => customFilters.remove(id);

  @override
  Future<void> insertLink(Link link) async => links[link.id] = link;

  @override
  Future<void> insertCollection(Collection collection) async =>
      collections[collection.id] = collection;

  @override
  Future<void> insertCustomFilter(CustomFilter filter) async =>
      customFilters[filter.id] = filter;

  @override
  Future<void> upsertSettings(AppSetting setting) async => settings = setting;

  // Unimplemented / stubbed for mock interface
  @override
  Stream<List<Link>> watchAllLinks() => Stream.value([]);
  @override
  Stream<List<Link>> watchInboxLinks() => Stream.value([]);
  @override
  Stream<List<Link>> watchArchiveLinks() => Stream.value([]);
  @override
  Future<void> updateLinkStatus(
    String id,
    LinkStatus status, {
    DateTime? readAt,
    DateTime? archivedAt,
  }) async {}
  @override
  Future<void> snoozeLink(
    String id,
    DateTime snoozedUntil,
    int snoozedSeconds,
  ) async {}
  @override
  Future<void> clearSnooze(String id) async {}
  @override
  Future<void> updateMetadata(
    String id, {
    String? title,
    String? faviconUrl,
    String? ogImageUrl,
    int? estimatedReadMinutes,
  }) async {}
  @override
  Future<void> updateLinkDeadStatus(String id, bool isDead) async {}
  @override
  Future<void> updateTags(String id, String tags) async {}
  @override
  Future<void> updateNotes(String id, String notes) async {}
  @override
  Future<void> updateLinkCollection(String id, String? collectionId) async {}
  @override
  Future<void> updateCustomHalfLife(
    String id,
    double? customHalfLifeDays,
  ) async {}
  @override
  Stream<List<Collection>> watchCollections() => Stream.value([]);
  @override
  Future<void> updateCollection(Collection collection) async {}
  @override
  Stream<List<CustomFilter>> watchCustomFilters() => Stream.value([]);
  @override
  Future<void> updateCustomFilter(CustomFilter filter) async {}
  @override
  Stream<List<LinkHighlight>> watchHighlightsForLink(String linkId) =>
      Stream.value([]);
  @override
  Future<void> insertHighlight(LinkHighlight highlight) async {}
  @override
  Future<void> deleteHighlight(String id) async {}
  @override
  Stream<AppSetting?> watchSettings() => Stream.value(null);
  @override
  Future<void> migrateUserData(
    String sourceUid,
    String targetUid, {
    bool onlyLinks = false,
  }) async {}
}

void main() {
  late MockFirestoreService mockFs;

  setUp(() {
    mockFs = MockFirestoreService();
    FirestoreService.instance = mockFs;
  });

  group('ExportService Import & Export Tests', () {
    test('JSON Import: Overwrite mode purges database first', () async {
      final exporter = ExportService.instance;

      // 1. Insert collection and link
      await mockFs.insertCollection(
        Collection(
          id: 'col_local',
          name: 'Local Collection',
          createdAt: DateTime.now(),
          sortOrder: 0,
        ),
      );
      await mockFs.insertLink(
        Link(
          id: 'link_local',
          url: 'https://flutter.dev',
          domain: 'flutter.dev',
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
          snoozedSeconds: 0,
          isDead: false,
          tags: '',
        ),
      );

      // Verify insertion
      final beforeLinks = await mockFs.getAllLinksFuture();
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
          },
        ],
        'links': [
          {
            'id': 'link_backup',
            'url': 'https://dart.dev',
            'domain': 'dart.dev',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'inbox',
          },
        ],
      };

      // 3. Run import in overwrite mode (merge: false)
      final count = await exporter.importFromJson(
        jsonEncode(backupJson),
        merge: false,
      );
      expect(count, 1);

      // 4. Verify local data is purged and replaced by backup data
      final afterLinks = await mockFs.getAllLinksFuture();
      expect(afterLinks.length, 1);
      expect(afterLinks.first.id, 'link_backup');
      expect(afterLinks.first.domain, 'dart.dev');

      final afterColls = await mockFs.getCollectionsFuture();
      expect(afterColls.length, 1);
      expect(afterColls.first.id, 'col_backup');
    });

    test('JSON Import: Merge mode keeps local database items', () async {
      final exporter = ExportService.instance;

      // 1. Insert local item
      await mockFs.insertLink(
        Link(
          id: 'link_local',
          url: 'https://flutter.dev',
          domain: 'flutter.dev',
          createdAt: DateTime.now(),
          status: LinkStatus.inbox,
          snoozedSeconds: 0,
          isDead: false,
          tags: '',
        ),
      );

      // 2. Prepare JSON backup
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
          },
        ],
      };

      // 3. Run import in merge mode (merge: true)
      final count = await exporter.importFromJson(
        jsonEncode(backupJson),
        merge: true,
      );
      expect(count, 1);

      // 4. Verify both items exist in the database
      final afterLinks = await mockFs.getAllLinksFuture();
      expect(afterLinks.length, 2);

      final ids = afterLinks.map((l) => l.id).toSet();
      expect(ids.contains('link_local'), true);
      expect(ids.contains('link_backup'), true);
    });

    test(
      'HTML Bookmarks Ingestion: Regex extracts HREF and title correctly',
      () async {
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

        final count = await exporter.importFromHtml(bookmarksHtml);
        expect(count, 2);

        final imported = await mockFs.getAllLinksFuture();
        expect(imported.length, 2);

        final hn = imported.firstWhere(
          (l) => l.domain == 'news.ycombinator.com',
        );
        expect(hn.url, 'https://news.ycombinator.com');
        expect(hn.title, 'Hacker News');
        expect(hn.tags, 'dev, news');

        final gh = imported.firstWhere((l) => l.domain == 'github.com');
        expect(gh.url, 'https://github.com');
        expect(gh.title, 'GitHub');
        expect(gh.tags, 'code');
      },
    );

    test(
      'JSON Import: Malformed JSON rolls back cleanly and doesn\'t save partial data',
      () async {
        final exporter = ExportService.instance;

        // 1. Insert local link first
        await mockFs.insertLink(
          Link(
            id: 'link_local',
            url: 'https://flutter.dev',
            domain: 'flutter.dev',
            createdAt: DateTime.now(),
            status: LinkStatus.inbox,
            snoozedSeconds: 0,
            isDead: false,
            tags: '',
          ),
        );

        // 2. Prepare malformed JSON (contains invalid date format which throws)
        final malformedBackupJson = {
          'version': 2,
          'collections': [
            {
              'id': 'col_success',
              'name': 'Success Coll',
              'createdAt': DateTime.now().toIso8601String(),
            },
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
              'createdAt':
                  'this-is-not-a-valid-date-format', // Will crash DateTime.parse()
              'status': 'inbox',
            },
          ],
        };

        // 3. Try to run import in overwrite mode. This should throw format exception.
        expect(
          () async => await exporter.importFromJson(
            jsonEncode(malformedBackupJson),
            merge: false,
          ),
          throwsA(isA<FormatException>()),
        );

        // 4. Verify transaction rolled back: original 'link_local' was restored
        final links = await mockFs.getAllLinksFuture();
        expect(links.length, 1);
        expect(links.first.id, 'link_local');

        // Verify no collections were saved either
        final colls = await mockFs.getCollectionsFuture();
        expect(colls.isEmpty, true);
      },
    );
  });
}
