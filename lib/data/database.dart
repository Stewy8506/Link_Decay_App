import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/link_status.dart';

part 'database.g.dart';

// ─── Table: Links ──────────────────────────────────────────────────────────

class Links extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();
  TextColumn get domain => text()();
  TextColumn get faviconUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  TextColumn get status => textEnum<LinkStatus>()();
  TextColumn get tags => text().withDefault(const Constant(''))();
  // Total seconds already spent snoozed (accumulated across multiple snoozes)
  IntColumn get snoozedSeconds => integer().withDefault(const Constant(0))();

  // Phase 1: Collections FK
  TextColumn get collectionId => text().nullable()();

  // Phase 2: Metadata and Notes
  TextColumn get notes => text().nullable()();
  TextColumn get ogImageUrl => text().nullable()();
  IntColumn get estimatedReadMinutes => integer().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  // Phase 8: Per-link decay override
  RealColumn get customHalfLifeDays => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Table: Collections ─────────────────────────────────────────────────────

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Table: CustomFilters (Smart Lists) ─────────────────────────────────────

class CustomFilters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('list'))();
  RealColumn get minFreshness => real().nullable()();
  RealColumn get maxFreshness => real().nullable()();
  TextColumn get tags => text().nullable()(); // Comma-separated tag inclusions
  TextColumn get collections => text().nullable()(); // Comma-separated collection ID inclusions
  TextColumn get domains => text().nullable()(); // Comma-separated domain inclusions
  IntColumn get minReadTime => integer().nullable()();
  IntColumn get maxReadTime => integer().nullable()();
  TextColumn get snoozeFilter => text().nullable()(); // 'all', 'exclude_snoozed', 'only_snoozed'
  TextColumn get sortField => text().withDefault(const Constant('freshness_asc'))(); // 'freshness_asc', 'freshness_desc', 'created_desc', 'created_asc', 'title_asc', 'read_time_asc'

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Table: LinkHighlights ──────────────────────────────────────────────────

class LinkHighlights extends Table {
  TextColumn get id => text()();
  TextColumn get linkId => text()(); // FK to Links
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Table: AppSettings ────────────────────────────────────────────────────

class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get halfLifeDays => real().withDefault(const Constant(7.0))();
  RealColumn get notificationThreshold => real().withDefault(const Constant(0.25))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(true))();

  // Phase 7 Customizations
  TextColumn get themePalette => text().withDefault(const Constant('warm_stone'))(); // 'warm_stone', 'cold_slate', 'forest_moss', 'pitch_charcoal'
  TextColumn get swipeLeftAction => text().withDefault(const Constant('archive'))(); // 'none', 'read', 'archive', 'delete', 'snooze', 'collection'
  TextColumn get swipeRightAction => text().withDefault(const Constant('read'))(); // 'none', 'read', 'archive', 'delete', 'snooze', 'collection'

  // Phase 8 Advanced Decay Overrides
  TextColumn get domainHalfLifeOverrides => text().nullable()(); // JSON serialized Map<String, double>
  TextColumn get tagHalfLifeOverrides => text().nullable()(); // JSON serialized Map<String, double>

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Links, Collections, CustomFilters, LinkHighlights, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Add new columns to Links
          await m.addColumn(links, links.collectionId);
          await m.addColumn(links, links.notes);
          await m.addColumn(links, links.ogImageUrl);
          await m.addColumn(links, links.estimatedReadMinutes);
          await m.addColumn(links, links.readAt);
          await m.addColumn(links, links.archivedAt);
          await m.addColumn(links, links.customHalfLifeDays);

          // Add new columns to AppSettings
          await m.addColumn(appSettings, appSettings.themePalette);
          await m.addColumn(appSettings, appSettings.swipeLeftAction);
          await m.addColumn(appSettings, appSettings.swipeRightAction);
          await m.addColumn(appSettings, appSettings.domainHalfLifeOverrides);
          await m.addColumn(appSettings, appSettings.tagHalfLifeOverrides);

          // Create new tables
          await m.createTable(collections);
          await m.createTable(customFilters);
          await m.createTable(linkHighlights);
        }
      },
    );
  }

  // ── Links ─────────────────────────────────────────────────────────────

  /// Stream of all links.
  Stream<List<Link>> watchAllLinks() {
    return select(links).watch();
  }

  /// Stream of inbox links ordered by createdAt ascending.
  Stream<List<Link>> watchInboxLinks() {
    return (select(links)
          ..where((l) => l.status.equalsValue(LinkStatus.inbox))
          ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
        .watch();
  }

  /// Stream of read + archived links for the archive screen.
  Stream<List<Link>> watchArchiveLinks() {
    return (select(links)
          ..where(
            (l) =>
                l.status.equalsValue(LinkStatus.read) |
                l.status.equalsValue(LinkStatus.archived),
          )
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
        .watch();
  }

  /// Insert a new link.
  Future<void> insertLink(LinksCompanion entry) async {
    await into(links).insert(entry);
  }

  /// Update link status (read / archived / inbox).
  Future<void> updateLinkStatus(String id, LinkStatus status) async {
    final now = DateTime.now();
    await (update(links)..where((l) => l.id.equals(id))).write(
      LinksCompanion(
        status: Value(status),
        readAt: status == LinkStatus.read ? Value(now) : const Value.absent(),
        archivedAt: status == LinkStatus.archived ? Value(now) : const Value.absent(),
      ),
    );
  }

  /// Snooze a link until [snoozedUntil], accumulating snoozed seconds.
  Future<void> snoozeLink(String id, DateTime snoozedUntil) async {
    final existing = await (select(links)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return;

    final now = DateTime.now();
    final additionalSeconds = snoozedUntil.difference(now).inSeconds;

    await (update(links)..where((l) => l.id.equals(id))).write(
      LinksCompanion(
        snoozedUntil: Value(snoozedUntil),
        snoozedSeconds: Value(existing.snoozedSeconds + additionalSeconds),
      ),
    );
  }

  /// Clear snooze after it expires.
  Future<void> clearSnooze(String id) async {
    await (update(links)..where((l) => l.id.equals(id))).write(
      const LinksCompanion(snoozedUntil: Value(null)),
    );
  }

  /// Delete a link permanently.
  Future<void> deleteLink(String id) async {
    await (delete(links)..where((l) => l.id.equals(id))).go();
  }

  /// Update title/favicon/meta after async metadata fetch.
  Future<void> updateMetadata(
    String id, {
    String? title,
    String? faviconUrl,
    String? ogImageUrl,
    int? estimatedReadMinutes,
  }) async {
    await (update(links)..where((l) => l.id.equals(id))).write(
      LinksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        faviconUrl: faviconUrl != null ? Value(faviconUrl) : const Value.absent(),
        ogImageUrl: ogImageUrl != null ? Value(ogImageUrl) : const Value.absent(),
        estimatedReadMinutes: estimatedReadMinutes != null ? Value(estimatedReadMinutes) : const Value.absent(),
      ),
    );
  }

  /// Update comma-separated tags string.
  Future<void> updateTags(String id, String tags) async {
    await (update(links)..where((l) => l.id.equals(id)))
        .write(LinksCompanion(tags: Value(tags)));
  }

  /// Update link notes.
  Future<void> updateNotes(String id, String notes) async {
    await (update(links)..where((l) => l.id.equals(id)))
        .write(LinksCompanion(notes: Value(notes)));
  }

  /// Update link's collection.
  Future<void> updateLinkCollection(String id, String? collectionId) async {
    await (update(links)..where((l) => l.id.equals(id)))
        .write(LinksCompanion(collectionId: Value(collectionId)));
  }

  /// Update custom half life overrides.
  Future<void> updateCustomHalfLife(String id, double? customHalfLifeDays) async {
    await (update(links)..where((l) => l.id.equals(id)))
        .write(LinksCompanion(customHalfLifeDays: Value(customHalfLifeDays)));
  }

  /// Get inbox links below a freshness threshold.
  Future<List<Link>> getStaleLinks({
    required double halfLifeDays,
    required double threshold,
  }) async {
    final now = DateTime.now();
    final allInbox = await (select(links)
          ..where((l) => l.status.equalsValue(LinkStatus.inbox)))
        .get();

    return allInbox.where((l) {
      final effectiveHalfLife = l.customHalfLifeDays ?? halfLifeDays;
      final ageDays = now.difference(l.createdAt).inDays.toDouble();
      final score = pow(0.5, ageDays / effectiveHalfLife).toDouble();
      return score < threshold;
    }).toList();
  }

  // ── Collections ────────────────────────────────────────────────────────

  Stream<List<Collection>> watchCollections() {
    return (select(collections)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();
  }

  Future<void> insertCollection(CollectionsCompanion entry) async {
    await into(collections).insert(entry);
  }

  Future<void> updateCollection(CollectionsCompanion entry) async {
    await (update(collections)..where((c) => c.id.equals(entry.id.value))).write(entry);
  }

  Future<void> deleteCollection(String id) async {
    // Set collectionId to null for all links belonging to this collection.
    await (update(links)..where((l) => l.collectionId.equals(id)))
        .write(const LinksCompanion(collectionId: Value(null)));
    // Delete the collection record.
    await (delete(collections)..where((c) => c.id.equals(id))).go();
  }

  // ── CustomFilters (Smart Lists) ────────────────────────────────────────

  Stream<List<CustomFilter>> watchCustomFilters() {
    return select(customFilters).watch();
  }

  Future<void> insertCustomFilter(CustomFiltersCompanion entry) async {
    await into(customFilters).insert(entry);
  }

  Future<void> updateCustomFilter(CustomFiltersCompanion entry) async {
    await (update(customFilters)..where((f) => f.id.equals(entry.id.value))).write(entry);
  }

  Future<void> deleteCustomFilter(String id) async {
    await (delete(customFilters)..where((f) => f.id.equals(id))).go();
  }

  // ── LinkHighlights ──────────────────────────────────────────────────────

  Stream<List<LinkHighlight>> watchHighlightsForLink(String linkId) {
    return (select(linkHighlights)
          ..where((h) => h.linkId.equals(linkId))
          ..orderBy([(h) => OrderingTerm.desc(h.createdAt)]))
        .watch();
  }

  Future<void> insertHighlight(LinkHighlightsCompanion entry) async {
    await into(linkHighlights).insert(entry);
  }

  Future<void> deleteHighlight(String id) async {
    await (delete(linkHighlights)..where((h) => h.id.equals(id))).go();
  }

  // ── Settings ──────────────────────────────────────────────────────────

  Future<AppSetting?> getSettings() async {
    return (select(appSettings)..where((s) => s.id.equals(1)))
        .getSingleOrNull();
  }

  Stream<AppSetting?> watchSettings() {
    return (select(appSettings)..where((s) => s.id.equals(1)))
        .watchSingleOrNull();
  }

  Future<void> upsertSettings(AppSettingsCompanion entry) async {
    await into(appSettings).insertOnConflictUpdate(entry);
  }
}

// ─── Connection ────────────────────────────────────────────────────────────

QueryExecutor _openConnection() {
  return driftDatabase(name: 'read_decay.db');
}
