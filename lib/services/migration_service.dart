import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart' as drift;
import '../models/models.dart' as firestore_models;
import 'firestore_service.dart';

class MigrationService {
  MigrationService._privateConstructor();
  static final MigrationService instance = MigrationService._privateConstructor();

  static const String _migratedPrefsKey = 'sqlite_migrated_to_firestore';

  /// Performs checks and copies legacy Drift data into Firestore.
  Future<void> checkAndMigrate(drift.AppDatabase driftDb, String uid) async {
    if (uid.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyMigrated = prefs.getBool(_migratedPrefsKey) ?? false;
      if (alreadyMigrated) {
        debugPrint('Legacy SQLite database has already been migrated to Firestore.');
        return;
      }

      // Check if drift tables actually contain data.
      final driftLinks = await driftDb.select(driftDb.links).get();
      final driftColls = await driftDb.select(driftDb.collections).get();

      if (driftLinks.isEmpty && driftColls.isEmpty) {
        debugPrint('Legacy SQLite database is empty. Marking migration as complete.');
        await prefs.setBool(_migratedPrefsKey, true);
        return;
      }

      debugPrint('Legacy SQLite data detected! Migrating ${driftLinks.length} links and ${driftColls.length} collections...');

      // Fetch other data
      final driftFilters = await driftDb.select(driftDb.customFilters).get();
      final driftHighlights = await driftDb.select(driftDb.linkHighlights).get();
      final driftSettings = await driftDb.getSettings();

      // 1. Copy Settings
      if (driftSettings != null) {
        await FirestoreService.instance.upsertSettings(
          firestore_models.AppSetting(
            halfLifeDays: driftSettings.halfLifeDays,
            notificationThreshold: driftSettings.notificationThreshold,
            notificationsEnabled: driftSettings.notificationsEnabled,
            isDarkMode: driftSettings.isDarkMode,
            themePalette: driftSettings.themePalette,
            swipeLeftAction: driftSettings.swipeLeftAction,
            swipeRightAction: driftSettings.swipeRightAction,
            domainHalfLifeOverrides: driftSettings.domainHalfLifeOverrides,
            tagHalfLifeOverrides: driftSettings.tagHalfLifeOverrides,
            dailyReadingGoal: driftSettings.dailyReadingGoal,
            snoozePresets: driftSettings.snoozePresets,
            fontFamily: driftSettings.fontFamily,
            customAccentColor: driftSettings.customAccentColor,
            customBgColor: driftSettings.customBgColor,
            decayCurveType: driftSettings.decayCurveType,
          ),
        );
      }

      // 2. Copy Collections
      for (final c in driftColls) {
        await FirestoreService.instance.insertCollection(
          firestore_models.Collection(
            id: c.id,
            name: c.name,
            emoji: c.emoji,
            createdAt: c.createdAt,
            sortOrder: c.sortOrder,
          ),
        );
      }

      // 3. Copy Custom Filters (Smart Lists)
      for (final f in driftFilters) {
        await FirestoreService.instance.insertCustomFilter(
          firestore_models.CustomFilter(
            id: f.id,
            name: f.name,
            icon: f.icon,
            minFreshness: f.minFreshness,
            maxFreshness: f.maxFreshness,
            tags: f.tags,
            collections: f.collections,
            domains: f.domains,
            minReadTime: f.minReadTime,
            maxReadTime: f.maxReadTime,
            snoozeFilter: f.snoozeFilter,
            sortField: f.sortField,
          ),
        );
      }

      // 4. Copy Links
      for (final l in driftLinks) {
        await FirestoreService.instance.insertLink(
          firestore_models.Link(
            id: l.id,
            url: l.url,
            title: l.title,
            domain: l.domain,
            faviconUrl: l.faviconUrl,
            createdAt: l.createdAt,
            snoozedUntil: l.snoozedUntil,
            status: l.status,
            tags: l.tags,
            snoozedSeconds: l.snoozedSeconds,
            collectionId: l.collectionId,
            notes: l.notes,
            ogImageUrl: l.ogImageUrl,
            estimatedReadMinutes: l.estimatedReadMinutes,
            readAt: l.readAt,
            archivedAt: l.archivedAt,
            customHalfLifeDays: l.customHalfLifeDays,
            isDead: l.isDead,
          ),
        );
      }

      // 5. Copy Highlights
      for (final h in driftHighlights) {
        await FirestoreService.instance.insertHighlight(
          firestore_models.LinkHighlight(
            id: h.id,
            linkId: h.linkId,
            content: h.content,
            createdAt: h.createdAt,
          ),
        );
      }

      // 6. Mark migration as finished
      await prefs.setBool(_migratedPrefsKey, true);
      debugPrint('Successfully completed SQLite to Firestore migration for user: $uid');
    } catch (e) {
      debugPrint('Error migrating SQLite to Firestore: $e');
    }
  }
}
