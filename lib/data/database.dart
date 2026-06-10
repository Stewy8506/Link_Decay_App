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

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Table: AppSettings ────────────────────────────────────────────────────

class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get halfLifeDays =>
      real().withDefault(const Constant(7.0))();
  RealColumn get notificationThreshold =>
      real().withDefault(const Constant(0.25))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isDarkMode =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Links, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Links ─────────────────────────────────────────────────────────────

  /// Stream of inbox links ordered by createdAt ascending (oldest = stalest first).
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

  /// Update link status (read / archived).
  Future<void> updateLinkStatus(String id, LinkStatus status) async {
    await (update(links)..where((l) => l.id.equals(id)))
        .write(LinksCompanion(status: Value(status)));
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

  /// Update title/favicon after async metadata fetch.
  Future<void> updateMetadata(
    String id, {
    String? title,
    String? faviconUrl,
  }) async {
    await (update(links)..where((l) => l.id.equals(id))).write(
      LinksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        faviconUrl:
            faviconUrl != null ? Value(faviconUrl) : const Value.absent(),
      ),
    );
  }

  /// Update comma-separated tags string.
  Future<void> updateTags(String id, String tags) async {
    await (update(links)..where((l) => l.id.equals(id)))
        .write(LinksCompanion(tags: Value(tags)));
  }

  /// Get inbox links below a freshness threshold (for notifications).
  Future<List<Link>> getStaleLinks({
    required double halfLifeDays,
    required double threshold,
  }) async {
    final now = DateTime.now();
    final allInbox = await (select(links)
          ..where((l) => l.status.equalsValue(LinkStatus.inbox)))
        .get();

    return allInbox.where((l) {
      final ageDays = now.difference(l.createdAt).inDays.toDouble();
      final score = pow(0.5, ageDays / halfLifeDays).toDouble();
      return score < threshold;
    }).toList();
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
