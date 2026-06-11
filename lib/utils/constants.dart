// Core application constants — colors, spacing, default settings.
import 'package:flutter/material.dart';

// ─── Dark Surface Palette (neutral carbon/stone) ───────────────────────────
const kBackgroundDark = Color(0xFF0C0C0C); // Near-black, neutral
const kSurfaceDark    = Color(0xFF161616); // Carbon
const kCardDark       = Color(0xFF1E1E1E); // Charcoal
const kBorderDark     = Color(0xFF2A2A2A); // No blue tint

// ─── Light Surface Palette (stone-based) ──────────────────────────────────
const kBackgroundLight = Color(0xFFFAFAF9); // Stone-50
const kSurfaceLight    = Color(0xFFF5F5F4); // Stone-100
const kCardLight       = Color(0xFFFFFFFF); // Pure white
const kBorderLight     = Color(0xFFE7E5E4); // Stone-200

// ─── Neutral Accent (warm stone) ──────────────────────────────────────────
const kAccent      = Color(0xFFA8A29E); // Stone-400 — warm stone
const kAccentMuted = Color(0xFF78716C); // Stone-500 — snooze/secondary

// ─── Text ─────────────────────────────────────────────────────────────────
const kTextPrimary   = Color(0xFFEDEDEC); // Stone-100 equivalent
const kTextSecondary = Color(0xFF888886); // Warm gray
const kTextTertiary  = Color(0xFF525250); // Mid-gray (slightly brighter for readability)

// ─── Freshness Colors (muted palette) ─────────────────────────────────────
// These are the ONLY intentional colors in the UI.
const kFreshnessHigh = Color(0xFF86EFAC); // Muted sage-green (green-300)
const kFreshnessMid  = Color(0xFFFBBF24); // Warm amber (amber-400)
const kFreshnessLow  = Color(0xFFFCA5A5); // Dusty rose (red-300)

// ─── Swipe Action Colors (neutral — matches stone accent) ─────────────────
const kSwipeReadColor    = Color(0xFFA8A29E); // Stone-400 (read = primary stone)
const kSwipeArchiveColor = Color(0xFF78716C); // Stone-500 (archive = secondary stone)

// ─── Default Settings ──────────────────────────────────────────────────────
const kDefaultHalfLifeDays            = 7.0;
const kDefaultNotificationThreshold   = 0.25;
const kDefaultNotificationsEnabled    = true;

// ─── Spacing ───────────────────────────────────────────────────────────────
const kSpaceXS  =  4.0;
const kSpaceSM  =  8.0;
const kSpaceMD  = 16.0;
const kSpaceLG  = 24.0;
const kSpaceXL  = 32.0;
const kSpaceXXL = 48.0;

// ─── Radius ────────────────────────────────────────────────────────────────
const kRadiusSM =  8.0;
const kRadiusMD = 12.0;
const kRadiusLG = 16.0;
const kRadiusXL = 24.0;

// ─── Animation Durations ───────────────────────────────────────────────────
const kDurationFast   = Duration(milliseconds: 150);
const kDurationNormal = Duration(milliseconds: 250);
const kDurationSlow   = Duration(milliseconds: 400);

// ─── App Info ──────────────────────────────────────────────────────────────
const kAppName    = 'ReadDecay';
const kAppVersion = '1.0.0';
