import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Computes the current freshness score for a link using exponential decay.
///
/// Formula: score = 0.5 ^ (effectiveAgeDays / halfLifeDays)
///
/// If the link is currently snoozed, effective age is frozen so that
/// decay pauses during the snooze period.
double computeFreshness({
  required DateTime createdAt,
  required DateTime now,
  required double halfLifeDays,
  DateTime? snoozedUntil,
  String decayCurveType = 'exponential',
}) {
  double ageDays;

  if (snoozedUntil != null && snoozedUntil.isAfter(now)) {
    // Currently snoozed: subtract remaining snooze so decay is paused.
    final remainingSnoozeMs = snoozedUntil.difference(now).inMilliseconds;
    final adjustedNow = now.subtract(Duration(milliseconds: remainingSnoozeMs));
    ageDays = adjustedNow.difference(createdAt).inMinutes / 1440.0;
    ageDays = ageDays.clamp(0.0, double.infinity);
  } else {
    ageDays = now.difference(createdAt).inMinutes / 1440.0;
  }

  if (halfLifeDays <= 0) return 0.0;

  double score;
  if (decayCurveType == 'linear') {
    score = 1.0 - (ageDays / (halfLifeDays * 2.0));
  } else {
    score = pow(0.5, ageDays / halfLifeDays).toDouble();
  }
  return score.clamp(0.0, 1.0);
}

/// Returns the age of a link in whole days.
int ageDays(DateTime createdAt, DateTime now) {
  return now.difference(createdAt).inDays;
}

/// Returns a human-friendly age string.
String ageLabel(DateTime createdAt, DateTime now) {
  final days = now.difference(createdAt).inDays;
  if (days == 0) {
    final hours = now.difference(createdAt).inHours;
    if (hours == 0) {
      final minutes = now.difference(createdAt).inMinutes;
      if (minutes < 2) return 'just now';
      return '$minutes min ago';
    }
    if (hours == 1) return '1 hr ago';
    return '$hours hrs ago';
  }
  if (days == 1) return 'yesterday';
  if (days < 7) return '$days days ago';
  if (days < 14) return '1 wk ago';
  if (days < 30) return '${(days / 7).floor()} wks ago';
  if (days < 60) return '1 month ago';
  return '${(days / 30).floor()} months ago';
}

/// Returns the freshness color based on score.
Color freshnessColor(double score) {
  if (score > 0.66) return kFreshnessHigh;
  if (score > 0.33) return kFreshnessMid;
  return kFreshnessLow;
}

/// Returns a text label for the freshness band.
String freshnessLabel(double score) {
  if (score > 0.8) return 'Fresh';
  if (score > 0.5) return 'Fading';
  if (score > 0.25) return 'Stale';
  return 'Critical';
}
