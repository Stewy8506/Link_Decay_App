import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../models/link_status.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static FirestoreService instance = FirestoreService._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Scoped user document reference helper
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> _linksRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('links');

  CollectionReference<Map<String, dynamic>> _collectionsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('collections');

  CollectionReference<Map<String, dynamic>> _filtersRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('custom_filters');

  CollectionReference<Map<String, dynamic>> _highlightsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('highlights');

  DocumentReference<Map<String, dynamic>> _settingsDoc(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('app_settings');

  // ─── Links Operations ──────────────────────────────────────────────────────

  Stream<List<Link>> watchAllLinks() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);
    return _linksRef(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Link.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Link>> watchInboxLinks() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);
    return _linksRef(
      uid,
    ).where('status', isEqualTo: LinkStatus.inbox.name).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => Link.fromMap(doc.data(), doc.id))
          .toList();
      // Drift ordered inbox links by createdAt ascending, let's keep that default logic
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Stream<List<Link>> watchArchiveLinks() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);
    return _linksRef(uid)
        .where(
          'status',
          whereIn: [LinkStatus.read.name, LinkStatus.archived.name],
        )
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Link.fromMap(doc.data(), doc.id))
              .toList();
          // Drift ordered archive links by createdAt descending, let's keep that logic
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<List<Link>> getAllLinksFuture() async {
    final uid = _uid;
    if (uid.isEmpty) return [];
    final snapshot = await _linksRef(uid).get();
    return snapshot.docs
        .map((doc) => Link.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> insertLink(Link link) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(link.id).set(link.toMap());
  }

  Future<void> updateLinkStatus(
    String id,
    LinkStatus status, {
    DateTime? readAt,
    DateTime? archivedAt,
  }) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final Map<String, dynamic> updates = {'status': status.name};
    if (readAt != null) updates['readAt'] = Timestamp.fromDate(readAt);
    if (archivedAt != null)
      updates['archivedAt'] = Timestamp.fromDate(archivedAt);
    await _linksRef(uid).doc(id).update(updates);
  }

  Future<void> snoozeLink(
    String id,
    DateTime snoozedUntil,
    int snoozedSeconds,
  ) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).update({
      'snoozedUntil': Timestamp.fromDate(snoozedUntil),
      'snoozedSeconds': snoozedSeconds,
    });
  }

  Future<void> clearSnooze(String id) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).update({'snoozedUntil': null});
  }

  Future<void> deleteLink(String id) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).delete();
  }

  Future<void> updateMetadata(
    String id, {
    String? title,
    String? faviconUrl,
    String? ogImageUrl,
    int? estimatedReadMinutes,
  }) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final Map<String, dynamic> updates = {};
    if (title != null) updates['title'] = title;
    if (faviconUrl != null) updates['faviconUrl'] = faviconUrl;
    if (ogImageUrl != null) updates['ogImageUrl'] = ogImageUrl;
    if (estimatedReadMinutes != null)
      updates['estimatedReadMinutes'] = estimatedReadMinutes;
    if (updates.isNotEmpty) {
      await _linksRef(uid).doc(id).update(updates);
    }
  }

  Future<void> updateLinkDeadStatus(String id, bool isDead) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).update({'isDead': isDead});
  }

  Future<void> updateTags(String id, String tags) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).update({'tags': tags});
  }

  Future<void> updateNotes(String id, String notes) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).update({'notes': notes});
  }

  Future<void> updateLinkCollection(String id, String? collectionId) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(uid).doc(id).update({'collectionId': collectionId});
  }

  Future<void> updateCustomHalfLife(
    String id,
    double? customHalfLifeDays,
  ) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _linksRef(
      uid,
    ).doc(id).update({'customHalfLifeDays': customHalfLifeDays});
  }

  // ─── Collections Operations ────────────────────────────────────────────────

  Stream<List<Collection>> watchCollections() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);
    return _collectionsRef(uid).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Collection.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Future<List<Collection>> getCollectionsFuture() async {
    final uid = _uid;
    if (uid.isEmpty) return [];
    final snapshot = await _collectionsRef(uid).get();
    final list = snapshot.docs
        .map((doc) => Collection.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<List<CustomFilter>> getFiltersFuture() async {
    final uid = _uid;
    if (uid.isEmpty) return [];
    final snapshot = await _filtersRef(uid).get();
    return snapshot.docs
        .map((doc) => CustomFilter.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> insertCollection(Collection collection) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _collectionsRef(uid).doc(collection.id).set(collection.toMap());
  }

  Future<void> updateCollection(Collection collection) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _collectionsRef(uid).doc(collection.id).update(collection.toMap());
  }

  Future<void> deleteCollection(String id) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final batch = _firestore.batch();

    // Set collectionId to null for all links belonging to this collection
    final linksSnap = await _linksRef(
      uid,
    ).where('collectionId', isEqualTo: id).get();
    for (final doc in linksSnap.docs) {
      batch.update(doc.reference, {'collectionId': null});
    }

    // Delete the collection document
    batch.delete(_collectionsRef(uid).doc(id));
    await batch.commit();
  }

  // ─── Custom Filters Operations ─────────────────────────────────────────────

  Stream<List<CustomFilter>> watchCustomFilters() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);
    return _filtersRef(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomFilter.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> insertCustomFilter(CustomFilter filter) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _filtersRef(uid).doc(filter.id).set(filter.toMap());
  }

  Future<void> updateCustomFilter(CustomFilter filter) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _filtersRef(uid).doc(filter.id).update(filter.toMap());
  }

  Future<void> deleteCustomFilter(String id) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _filtersRef(uid).doc(id).delete();
  }

  // ─── Link Highlights Operations ────────────────────────────────────────────

  Stream<List<LinkHighlight>> watchHighlightsForLink(String linkId) {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);
    return _highlightsRef(
      uid,
    ).where('linkId', isEqualTo: linkId).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => LinkHighlight.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> insertHighlight(LinkHighlight highlight) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _highlightsRef(uid).doc(highlight.id).set(highlight.toMap());
  }

  Future<void> deleteHighlight(String id) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _highlightsRef(uid).doc(id).delete();
  }

  // ─── App Settings Operations ───────────────────────────────────────────────

  Future<AppSetting?> getSettings() async {
    final uid = _uid;
    if (uid.isEmpty) return null;
    final doc = await _settingsDoc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppSetting.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<AppSetting?> watchSettings() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value(null);
    return _settingsDoc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppSetting.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<void> upsertSettings(AppSetting setting) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _settingsDoc(uid).set(setting.toMap(), SetOptions(merge: true));
  }

  // ─── Scoped Data Migration Helper ──────────────────────────────────────────

  /// Merges user database from [sourceUid] to [targetUid].
  /// If [onlyLinks] is true, it only migrates the 'links' collection.
  Future<void> migrateUserData(
    String sourceUid,
    String targetUid, {
    bool onlyLinks = false,
  }) async {
    if (sourceUid.isEmpty || targetUid.isEmpty || sourceUid == targetUid)
      return;

    final batchSize = 100;

    // 1. Copy Links
    final linksSnapshot = await _linksRef(sourceUid).get();
    if (linksSnapshot.docs.isNotEmpty) {
      var batch = _firestore.batch();
      var count = 0;
      for (final doc in linksSnapshot.docs) {
        batch.set(_linksRef(targetUid).doc(doc.id), doc.data());
        batch.delete(doc.reference); // Delete source
        count++;
        if (count >= batchSize) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }
      if (count > 0) {
        await batch.commit();
      }
    }

    if (onlyLinks) return;

    // 2. Copy Collections
    final collectionsSnapshot = await _collectionsRef(sourceUid).get();
    if (collectionsSnapshot.docs.isNotEmpty) {
      var batch = _firestore.batch();
      var count = 0;
      for (final doc in collectionsSnapshot.docs) {
        batch.set(_collectionsRef(targetUid).doc(doc.id), doc.data());
        batch.delete(doc.reference);
        count++;
        if (count >= batchSize) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }
      if (count > 0) {
        await batch.commit();
      }
    }

    // 3. Copy Custom Filters
    final filtersSnapshot = await _filtersRef(sourceUid).get();
    if (filtersSnapshot.docs.isNotEmpty) {
      var batch = _firestore.batch();
      var count = 0;
      for (final doc in filtersSnapshot.docs) {
        batch.set(_filtersRef(targetUid).doc(doc.id), doc.data());
        batch.delete(doc.reference);
        count++;
        if (count >= batchSize) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }
      if (count > 0) {
        await batch.commit();
      }
    }

    // 4. Copy Highlights
    final highlightsSnapshot = await _highlightsRef(sourceUid).get();
    if (highlightsSnapshot.docs.isNotEmpty) {
      var batch = _firestore.batch();
      var count = 0;
      for (final doc in highlightsSnapshot.docs) {
        batch.set(_highlightsRef(targetUid).doc(doc.id), doc.data());
        batch.delete(doc.reference);
        count++;
        if (count >= batchSize) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }
      if (count > 0) {
        await batch.commit();
      }
    }

    // 5. Copy Settings
    final settingsSnapshot = await _settingsDoc(sourceUid).get();
    if (settingsSnapshot.exists && settingsSnapshot.data() != null) {
      await _settingsDoc(targetUid).set(settingsSnapshot.data()!);
      await _settingsDoc(sourceUid).delete();
    }
  }
}
