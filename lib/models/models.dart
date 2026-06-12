import 'package:cloud_firestore/cloud_firestore.dart';
import 'link_status.dart';

// Helper to convert Firebase fields (can be Timestamp, String, or DateTime) to DateTime.
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is DateTime) return value;
  return null;
}

// Helper to parse double fields safely (handles both double and int)
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return null;
}

// ─── Model: Link ─────────────────────────────────────────────────────────────

class Link {
  final String id;
  final String url;
  final String? title;
  final String domain;
  final String? faviconUrl;
  final DateTime createdAt;
  final DateTime? snoozedUntil;
  final LinkStatus status;
  final String tags;
  final int snoozedSeconds;
  final String? collectionId;
  final String? notes;
  final String? ogImageUrl;
  final int? estimatedReadMinutes;
  final DateTime? readAt;
  final DateTime? archivedAt;
  final double? customHalfLifeDays;
  final bool isDead;

  Link({
    required this.id,
    required this.url,
    this.title,
    required this.domain,
    this.faviconUrl,
    required this.createdAt,
    this.snoozedUntil,
    required this.status,
    required this.tags,
    required this.snoozedSeconds,
    this.collectionId,
    this.notes,
    this.ogImageUrl,
    this.estimatedReadMinutes,
    this.readAt,
    this.archivedAt,
    this.customHalfLifeDays,
    required this.isDead,
  });

  factory Link.fromMap(Map<String, dynamic> map, String docId) {
    return Link(
      id: docId,
      url: map['url'] ?? '',
      title: map['title'],
      domain: map['domain'] ?? '',
      faviconUrl: map['faviconUrl'],
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      snoozedUntil: _parseDateTime(map['snoozedUntil']),
      status: LinkStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LinkStatus.inbox,
      ),
      tags: map['tags'] ?? '',
      snoozedSeconds: map['snoozedSeconds'] ?? 0,
      collectionId: map['collectionId'],
      notes: map['notes'],
      ogImageUrl: map['ogImageUrl'],
      estimatedReadMinutes: map['estimatedReadMinutes'],
      readAt: _parseDateTime(map['readAt']),
      archivedAt: _parseDateTime(map['archivedAt']),
      customHalfLifeDays: _parseDouble(map['customHalfLifeDays']),
      isDead: map['isDead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'domain': domain,
      'faviconUrl': faviconUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'snoozedUntil': snoozedUntil != null ? Timestamp.fromDate(snoozedUntil!) : null,
      'status': status.name,
      'tags': tags,
      'snoozedSeconds': snoozedSeconds,
      'collectionId': collectionId,
      'notes': notes,
      'ogImageUrl': ogImageUrl,
      'estimatedReadMinutes': estimatedReadMinutes,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'customHalfLifeDays': customHalfLifeDays,
      'isDead': isDead,
    };
  }
}

// ─── Model: Collection ───────────────────────────────────────────────────────

class Collection {
  final String id;
  final String name;
  final String? emoji;
  final DateTime createdAt;
  final int sortOrder;

  Collection({
    required this.id,
    required this.name,
    this.emoji,
    required this.createdAt,
    required this.sortOrder,
  });

  factory Collection.fromMap(Map<String, dynamic> map, String docId) {
    return Collection(
      id: docId,
      name: map['name'] ?? '',
      emoji: map['emoji'],
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
      'sortOrder': sortOrder,
    };
  }
}

// ─── Model: CustomFilter (Smart Lists) ──────────────────────────────────────

class CustomFilter {
  final String id;
  final String name;
  final String icon;
  final double? minFreshness;
  final double? maxFreshness;
  final String? tags;
  final String? collections;
  final String? domains;
  final int? minReadTime;
  final int? maxReadTime;
  final String? snoozeFilter;
  final String sortField;

  CustomFilter({
    required this.id,
    required this.name,
    required this.icon,
    this.minFreshness,
    this.maxFreshness,
    this.tags,
    this.collections,
    this.domains,
    this.minReadTime,
    this.maxReadTime,
    this.snoozeFilter,
    required this.sortField,
  });

  factory CustomFilter.fromMap(Map<String, dynamic> map, String docId) {
    return CustomFilter(
      id: docId,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'list',
      minFreshness: _parseDouble(map['minFreshness']),
      maxFreshness: _parseDouble(map['maxFreshness']),
      tags: map['tags'],
      collections: map['collections'],
      domains: map['domains'],
      minReadTime: map['minReadTime'],
      maxReadTime: map['maxReadTime'],
      snoozeFilter: map['snoozeFilter'],
      sortField: map['sortField'] ?? 'freshness_asc',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'minFreshness': minFreshness,
      'maxFreshness': maxFreshness,
      'tags': tags,
      'collections': collections,
      'domains': domains,
      'minReadTime': minReadTime,
      'maxReadTime': maxReadTime,
      'snoozeFilter': snoozeFilter,
      'sortField': sortField,
    };
  }
}

// ─── Model: LinkHighlight ───────────────────────────────────────────────────

class LinkHighlight {
  final String id;
  final String linkId;
  final String content;
  final DateTime createdAt;

  LinkHighlight({
    required this.id,
    required this.linkId,
    required this.content,
    required this.createdAt,
  });

  factory LinkHighlight.fromMap(Map<String, dynamic> map, String docId) {
    return LinkHighlight(
      id: docId,
      linkId: map['linkId'] ?? '',
      content: map['content'] ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'linkId': linkId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// ─── Model: AppSetting ───────────────────────────────────────────────────────

class AppSetting {
  final double halfLifeDays;
  final double notificationThreshold;
  final bool notificationsEnabled;
  final bool isDarkMode;
  final String themePalette;
  final String swipeLeftAction;
  final String swipeRightAction;
  final String? domainHalfLifeOverrides;
  final String? tagHalfLifeOverrides;
  final int dailyReadingGoal;
  final String snoozePresets;
  final String fontFamily;
  final String? customAccentColor;
  final String? customBgColor;
  final String decayCurveType;

  AppSetting({
    required this.halfLifeDays,
    required this.notificationThreshold,
    required this.notificationsEnabled,
    required this.isDarkMode,
    required this.themePalette,
    required this.swipeLeftAction,
    required this.swipeRightAction,
    this.domainHalfLifeOverrides,
    this.tagHalfLifeOverrides,
    required this.dailyReadingGoal,
    required this.snoozePresets,
    required this.fontFamily,
    this.customAccentColor,
    this.customBgColor,
    required this.decayCurveType,
  });

  factory AppSetting.fromMap(Map<String, dynamic> map) {
    return AppSetting(
      halfLifeDays: _parseDouble(map['halfLifeDays']) ?? 7.0,
      notificationThreshold: _parseDouble(map['notificationThreshold']) ?? 0.25,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      isDarkMode: map['isDarkMode'] ?? true,
      themePalette: map['themePalette'] ?? 'warm_stone',
      swipeLeftAction: map['swipeLeftAction'] ?? 'archive',
      swipeRightAction: map['swipeRightAction'] ?? 'read',
      domainHalfLifeOverrides: map['domainHalfLifeOverrides'],
      tagHalfLifeOverrides: map['tagHalfLifeOverrides'],
      dailyReadingGoal: map['dailyReadingGoal'] ?? 2,
      snoozePresets: map['snoozePresets'] ?? '[1, 3, 7]',
      fontFamily: map['fontFamily'] ?? 'inter',
      customAccentColor: map['customAccentColor'],
      customBgColor: map['customBgColor'],
      decayCurveType: map['decayCurveType'] ?? 'exponential',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'halfLifeDays': halfLifeDays,
      'notificationThreshold': notificationThreshold,
      'notificationsEnabled': notificationsEnabled,
      'isDarkMode': isDarkMode,
      'themePalette': themePalette,
      'swipeLeftAction': swipeLeftAction,
      'swipeRightAction': swipeRightAction,
      'domainHalfLifeOverrides': domainHalfLifeOverrides,
      'tagHalfLifeOverrides': tagHalfLifeOverrides,
      'dailyReadingGoal': dailyReadingGoal,
      'snoozePresets': snoozePresets,
      'fontFamily': fontFamily,
      'customAccentColor': customAccentColor,
      'customBgColor': customBgColor,
      'decayCurveType': decayCurveType,
    };
  }

  // Helper factory for default values
  factory AppSetting.defaults() {
    return AppSetting(
      halfLifeDays: 7.0,
      notificationThreshold: 0.25,
      notificationsEnabled: true,
      isDarkMode: true,
      themePalette: 'warm_stone',
      swipeLeftAction: 'archive',
      swipeRightAction: 'read',
      dailyReadingGoal: 2,
      snoozePresets: '[1, 3, 7]',
      fontFamily: 'inter',
      decayCurveType: 'exponential',
    );
  }
}
