import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../models/link_status.dart';


class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'linkshelf_daily';
  static const _channelName = 'Daily Freshness Check';
  static const _channelDesc =
      'Notifies you when saved links are getting stale.';
  static const _notificationId = 1001;

  Future<void> initialize() async {
    if (kIsWeb) return;

    // Initialize time zones and set local location
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }

    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: false,
          ) ??
          false;
    }

    return true;
  }

  /// Schedule a daily notification at 9 AM local time if there are stale links.
  Future<void> scheduleDailyCheck({
    required AppDatabase db,
    required double halfLifeDays,
    required double threshold,
    String decayCurveType = 'exponential',
  }) async {
    if (kIsWeb) return;

    await _plugin.cancelAll();

    final staleLinks = await db.getStaleLinks(
      halfLifeDays: halfLifeDays,
      threshold: threshold,
      decayCurveType: decayCurveType,
    );

    if (staleLinks.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9, // 9 AM
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final count = staleLinks.length;
    final body = count == 1
        ? '1 saved link is getting stale — time to read it!'
        : '$count saved links are getting stale — time to catch up!';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      _notificationId,
      'LinkShelf',
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedule a weekly digest notification on Sunday at 6 PM.
  Future<void> scheduleWeeklyDigest({
    required AppDatabase db,
    required double halfLifeDays,
    String decayCurveType = 'exponential',
  }) async {
    if (kIsWeb) return;

    final links = await db.select(db.links).get();

    // 1. Calculate stale links (freshness < 0.25)
    final nowTime = DateTime.now();
    int staleCount = 0;
    for (final l in links) {
      if (l.status == LinkStatus.inbox) {
        final score = _computeFreshnessLocal(
          createdAt: l.createdAt,
          now: nowTime,
          halfLifeDays: l.customHalfLifeDays ?? halfLifeDays,
          snoozedUntil: l.snoozedUntil,
          decayCurveType: decayCurveType,
        );
        if (score < 0.25) {
          staleCount++;
        }
      }
    }

    // 2. Read links in last 7 days
    final sevenDaysAgo = nowTime.subtract(const Duration(days: 7));
    final readLast7Days = links.where((l) => l.readAt != null && l.readAt!.isAfter(sevenDaysAgo)).length;

    // 3. Current reading streak
    final readDates = links
        .where((l) => l.readAt != null)
        .map((l) => DateTime(l.readAt!.year, l.readAt!.month, l.readAt!.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    if (readDates.isNotEmpty) {
      final today = DateTime(nowTime.year, nowTime.month, nowTime.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      if (readDates.contains(today) || readDates.contains(yesterday)) {
        currentStreak = 1;
        var checkDate = readDates.contains(today) ? today : yesterday;
        
        while (true) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          if (readDates.contains(checkDate)) {
            currentStreak++;
          } else {
            break;
          }
        }
      }
    }

    // Compose notification content
    final title = 'Your Weekly LinkShelf Digest';
    final body = 'You read $readLast7Days links this week! 🔥 Current streak: $currentStreak days. $staleCount links are getting stale and need your attention.';

    // Schedule for next Sunday at 6 PM
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18, // 6 PM
    );

    // Find the next Sunday (Sunday is day 7 in timezone/datetime library)
    while (scheduledDate.weekday != DateTime.sunday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      'linkshelf_weekly',
      'Weekly Digest',
      channelDescription: 'Weekly summary of your reading stats.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      1002, // Weekly ID
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  double _computeFreshnessLocal({
    required DateTime createdAt,
    required DateTime now,
    required double halfLifeDays,
    DateTime? snoozedUntil,
    String decayCurveType = 'exponential',
  }) {
    if (snoozedUntil != null && snoozedUntil.isAfter(now)) {
      // Pause decay while snoozed
      return 1.0;
    }
    final ageMs = now.difference(createdAt).inMilliseconds;
    final halfLifeMs = halfLifeDays * 24 * 60 * 60 * 1000;
    if (halfLifeMs <= 0) return 0.0;
    if (decayCurveType == 'linear') {
      final ageDays = ageMs / (24.0 * 60.0 * 60.0 * 1000.0);
      return (1.0 - (ageDays / (halfLifeDays * 2.0))).clamp(0.0, 1.0);
    }
    return pow(0.5, ageMs / halfLifeMs).toDouble();
  }

  /// Push a local success notification immediately.
  Future<void> showImmediateNotification(String title, String body) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'linkshelf_share',
      'Share Intent Adds',
      channelDescription: 'Notifies when links are saved from share sheet.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Use a unique ID for each immediate notification
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    await _plugin.show(
      notificationId,
      title,
      body,
      details,
    );
  }
}

