// Core application constants — colors, spacing, default settings.
import 'package:flutter/material.dart';

// ─── Brand Colors ──────────────────────────────────────────────────────────
const kBackgroundDark = Color(0xFF0A0A0B);
const kSurfaceDark = Color(0xFF141416);
const kCardDark = Color(0xFF1C1C1F);
const kBorderDark = Color(0xFF2A2A2F);

const kBackgroundLight = Color(0xFFFAFAF8);
const kSurfaceLight = Color(0xFFF3F3F0);
const kCardLight = Color(0xFFFFFFFF);
const kBorderLight = Color(0xFFE8E8E4);

const kAccent = Color(0xFFE8927C); // Warm salmon/terracotta
const kAccentMuted = Color(0xFF8B5CF6); // Purple for snoozed state
const kTextPrimary = Color(0xFFF2F2F0);
const kTextSecondary = Color(0xFF8A8A8E);
const kTextTertiary = Color(0xFF4A4A4F);

// ─── Freshness Colors ──────────────────────────────────────────────────────
const kFreshnessHigh = Color(0xFF22C55E); // > 0.66
const kFreshnessMid = Color(0xFFEAB308); // 0.33 – 0.66
const kFreshnessLow = Color(0xFFEF4444); // < 0.33

// ─── Swipe Colors ─────────────────────────────────────────────────────────
const kSwipeReadColor = Color(0xFF22C55E);
const kSwipeArchiveColor = Color(0xFF3B82F6);

// ─── Default Settings ──────────────────────────────────────────────────────
const kDefaultHalfLifeDays = 7.0;
const kDefaultNotificationThreshold = 0.25;
const kDefaultNotificationsEnabled = true;

// ─── Spacing ───────────────────────────────────────────────────────────────
const kSpaceXS = 4.0;
const kSpaceSM = 8.0;
const kSpaceMD = 16.0;
const kSpaceLG = 24.0;
const kSpaceXL = 32.0;
const kSpaceXXL = 48.0;

// ─── Radius ────────────────────────────────────────────────────────────────
const kRadiusSM = 8.0;
const kRadiusMD = 12.0;
const kRadiusLG = 16.0;
const kRadiusXL = 24.0;

// ─── Animation Durations ───────────────────────────────────────────────────
const kDurationFast = Duration(milliseconds: 150);
const kDurationNormal = Duration(milliseconds: 250);
const kDurationSlow = Duration(milliseconds: 400);

// ─── App Info ──────────────────────────────────────────────────────────────
const kAppName = 'ReadDecay';
const kAppVersion = '1.0.0';
