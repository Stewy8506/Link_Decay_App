<div align="center">

<br/>

```
██████╗ ███████╗ █████╗ ██████╗     ██████╗ ███████╗ ██████╗ █████╗ ██╗   ██╗
██╔══██╗██╔════╝██╔══██╗██╔══██╗    ██╔══██╗██╔════╝██╔════╝██╔══██╗╚██╗ ██╔╝
██████╔╝█████╗  ███████║██║  ██║    ██║  ██║█████╗  ██║     ███████║ ╚████╔╝
██╔══██╗██╔══╝  ██╔══██║██║  ██║    ██║  ██║██╔══╝  ██║     ██╔══██║  ╚██╔╝
██║  ██║███████╗██║  ██║██████╔╝    ██████╔╝███████╗╚██████╗██║  ██║   ██║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝     ╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝
```

**Your reading list, decaying in real time.**

*Save it or lose it.*

[![Flutter](https://img.shields.io/badge/Flutter-3.41.2-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.0-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![Drift](https://img.shields.io/badge/Drift-ORM-4A90E2?style=flat-square)](https://drift.simonbinder.eu)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=flat-square)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android)](https://android.com)

<br/>

> **ReadDecay** is a local-first reading list manager with a twist — every link you save has a **freshness score** that exponentially decays over time. The longer you wait, the staler it gets. Links you haven't read sort to the top, glowing red, demanding your attention. Read them, snooze them, organize them, or watch them fade.

<br/>

</div>

---

## ✦ The Concept

Most read-later apps treat your reading list like an infinite warehouse — links pile up forever, sorted by date, never asking you to act. **ReadDecay treats your reading list like a perishable.** Every link has a shelf life.

The core mechanic is **exponential decay**:

```
freshness(t) = 0.5 ^ (effectiveAge / halfLife)
```

A link saved today scores `1.0`. After one half-life (default: 7 days), it scores `0.5`. After two, `0.25`. The inbox sorts by ascending freshness — **the most stale links rise to the top**, creating urgency through visual pressure. A color-coded bar shifts from `green → yellow → orange → red` as time passes.

It's gamified procrastination therapy.

---

## ✦ Implemented Features

### 📥 Inbox
- **Automatic metadata fetching** — Saves a URL and immediately fetches the page title, description, cover image, reading time estimation, and favicon in the background (using Open Graph parser + Google S2 favicon fallback).
- **Freshness-sorted list** — The most stale links always surface at the top to highlight reading priority.
- **Per-card freshness bar** — Animated, color-coded status bar (`green → yellow → orange → red`).
- **Numeric score badge** — Displays exact freshness value (0.00 – 1.00) directly on each card.
- **Age label** — Human-readable age representation ("just now", "3 days ago", "2 wks ago").
- **Domain + favicon** — Extracted from URL, with lettermark fallback if favicon fails.
- **Tag chips** — Inline tag display on each card (up to 3 visible tags).
- **Half-life info bar** — Shows current global half-life decay rate at the top of the list.
- **Link count badge** — Live count of inbox items in the app bar.
- **Full-text search** — Filters by title, domain, and tags live as you type.

### 📂 Collections & Folder System
- **Folders Grid View** — Dedicated collections screen to group and organize links with custom names, emoji icons, active link counts, and **Average Freshness** scores calculated dynamically.
- **Manage Folders** — Edit folder details (rename, change emoji) or delete folders (deleting folders safely returns their links back to the general Inbox).
- **Direct Folder Ingestion** — FloatingActionButton inside any folder view to immediately save a link into that specific folder.
- **Add-Link Pre-selection** — Horizontal folder selection chips inside the add sheet to assign a folder during ingestion.

### ⚡ Smart Lists (Custom Filters)
- **Horizontal Preset Bar** — Quick selection chips located below the search bar to filter the inbox instantly.
- **Interactive Custom Filters Builder** — Build custom rule-based lists using:
  - Custom list name and icon emoji.
  - Freshness score boundaries (e.g. only show "Fresh" or "Critical" links).
  - Estimated reading time bounds (e.g. "< 5 mins" for quick reads).
  - Tag inclusions.
  - Folder/Collection scope.
  - Domain filter matches.
  - Snooze status filter (Include all, exclude snoozed, or only snoozed).
  - Default sorting rules specifically for each list (Stalest first, Freshest first, Reading Time, Title, Created Date).

### 📊 Performance Insights Stats Dashboard
- **Overscroll Pull-Down** — Pull down from the Inbox screen header to trigger haptic feedback and smoothly animate (`AnimatedSize`) the stats panel open.
- **Habit Metrics** — Tracks reading streaks (consecutive days of reading), total read links count, and active inbox count.
- **Saved vs Read Velocity Chart** — 7-day visual bar chart tracking links saved vs. links read.
- **Inbox Health Band** — Stacked distribution bar representing the breakdown of Fresh, Fading, and Stale items.
- **Top Domain Sources** — Chips of the most frequently saved website domains.

### 📝 Link Details, Notes & Quote Highlights
- **Banner Header** — Blur cover photo parsed from page metadata overlaying the page title.
- **Rename Title** — Tap the edit pencil button next to the title to assign custom titles/names to your links.
- **Personal Notes** — Fully editable notes container to write key takeaways.
- **Quotes Highlights** — Paste key quotes or snippets from the article into a swipe-to-delete collection.
- **Granular Decay Overrides** — Override the global half-life for this specific link using a slider (1 to 30 days).
- **Link History Logs** — Time logs indicating when the link was added, read, archived, and total accumulated hours spent snoozed.

### 🗳️ Bulk Actions (Multi-Select)
- **Selection Mode** — Long-press any link card to enter multi-select mode.
- **Animated Navbar Transition** — The bottom navigation bar and gradient fade automatically slide off-screen during selection mode to optimize screen real estate.
- **Floating Actions Bar** — Bulk mark read, archive, delete, tag, or move selected links to folders.

### 😴 Snooze
- **Quick snoozing** — Pause link decay for 1 day, 3 days, or 1 week.
- Decay **pauses** for the entire snooze duration (effective age freezes).
- Snoozed items show a `⏸ Snoozed until [Date]` badge on the card.
- Snooze history accumulates — multiple snoozes stack correctly.

### ➕ Add Links
- Paste any URL manually into the add sheet with clipboard auto-detection.
- Custom title field to name links prior to ingest.
- Folder selection chips to save links directly into collections.
- Validates and auto-normalizes URLs (adds `https://` if missing).
- Shows animated loading state while fetching metadata.
- **Share sheet** (Android) — Share any URL from Chrome, Twitter, etc. directly into the app.

### 💾 Data Tools (Backup & Restore)
- **HTML Bookmarks** — Import and export Netscape HTML bookmarks (e.g. from Chrome, Safari, Pocket).
- **JSON Backup** — Export and share a full database JSON backup. Import JSON backups with choice of *Merge* (keep local links) or *Overwrite* (purge tables first) restore strategies.

### 👆 Gestures Customizer
- Configure what **Swipe Left** and **Swipe Right** gestures do on link cards directly from settings (`None`, `Read`, `Archive`, `Snooze`, `Folder Picker`, or `Delete`).

### 🎨 Appearance & Themes
- Toggle light and dark modes.
- Select among four minimalist, neutral theme palettes: **Warm Stone** (Default), **Cold Slate**, **Forest Moss**, and **Pitch Charcoal**.

---

## ✦ Project Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer                            │
│  InboxScreen       CollectionsScreen  SettingsScreen    │
│  LinkDetailScreen  CustomFilterCreatorScreen            │
│  LinkCard  MultiSelectBar  SmartListBar  AddLinkSheet   │
└─────────────────────┬───────────────────────────────────┘
                      │ watches / reads providers
┌─────────────────────▼───────────────────────────────────┐
│                 State Layer (Riverpod 2.x)               │
│  inboxLinksProvider      → StreamProvider<List<Link>>   │
│  collectionsProvider     → StreamProvider<List<Coll>>   │
│  customFiltersProvider   → StreamProvider<List<Filter>> │
│  settingsProvider        → StreamProvider<AppSetting?>  │
│  sortedFilteredInbox     → Provider (search + smart filter)│
│  linkActionsProvider     → NotifierProvider (mutations) │
└─────────────────────┬───────────────────────────────────┘
                      │ reads / writes
┌─────────────────────▼───────────────────────────────────┐
│                  Data Layer                             │
│  AppDatabase (Drift + SQLite)                          │
│    Links table         Collections table                │
│    CustomFilters       LinkHighlights                   │
│    AppSettings table                                    │
│  MetadataService       ExportService                    │
│  NotificationService   ShareIntentService               │
└─────────────────────────────────────────────────────────┘
```

### Freshness Decay Model

```dart
// Effective age accounts for total time spent snoozed
score = pow(0.5, effectiveAgeDays / halfLifeDays)

// If currently snoozed, remaining snooze time is subtracted
// from effective age — decay is completely paused.
```

| Score | Label | Color | Bar |
|---|---|---|---|
| `> 0.80` | Fresh | 🟢 Green | `████████░░` |
| `0.50 – 0.80` | Fading | 🟡 Yellow | `█████░░░░░` |
| `0.25 – 0.50` | Stale | 🟠 Orange | `███░░░░░░░` |
| `< 0.25` | Critical | 🔴 Red | `██░░░░░░░░` |

---

## ✦ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.41.2 · Dart 3.11.0 |
| **Database** | [Drift](https://drift.simonbinder.eu) (type-safe SQLite ORM) |
| **State** | [Riverpod](https://riverpod.dev) 2.x |
| **Fonts** | [Inter](https://rsms.me/inter/) via `google_fonts` |
| **Networking** | `http` · `html` (HTML scraping) |
| **Notifications** | `flutter_local_notifications` v18 + `timezone` |
| **Share** | `receive_sharing_intent` · `share_plus` |
| **File Picker** | `file_picker` (JSON / HTML imports) |
| **URL Launcher** | `url_launcher` |
| **Favicon** | Google S2 Favicon API (`s2.favicons?domain=...&sz=64`) |

### Database Schema (Version 2)

```sql
-- Links table
CREATE TABLE links (
  id                      TEXT PRIMARY KEY,
  url                     TEXT NOT NULL,
  title                   TEXT,
  domain                  TEXT NOT NULL,
  favicon_url             TEXT,
  created_at              INTEGER NOT NULL,
  snoozed_until           INTEGER,
  status                  TEXT NOT NULL, -- 'inbox' | 'read' | 'archived'
  tags                    TEXT DEFAULT '',
  snoozed_seconds         INTEGER DEFAULT 0,
  collection_id           TEXT, -- FK references collections(id)
  notes                   TEXT,
  og_image_url            TEXT,
  estimated_read_minutes  INTEGER,
  read_at                 INTEGER,
  archived_at             INTEGER,
  custom_half_life_days   REAL
);

-- Collections table
CREATE TABLE collections (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  emoji       TEXT,
  created_at  INTEGER NOT NULL,
  sort_order  INTEGER DEFAULT 0
);

-- Custom Filters (Smart Lists) table
CREATE TABLE custom_filters (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  icon            TEXT NOT NULL,
  min_freshness   REAL,
  max_freshness   REAL,
  tags            TEXT,
  collections     TEXT,
  domains         TEXT,
  min_read_time   INTEGER,
  max_read_time   INTEGER,
  snooze_filter   TEXT,
  sort_field      TEXT NOT NULL
);

-- Highlights table
CREATE TABLE link_highlights (
  id          TEXT PRIMARY KEY,
  link_id     TEXT NOT NULL, -- FK references links(id)
  content     TEXT NOT NULL,
  created_at  INTEGER NOT NULL
);

-- App settings (single-row, id = 1)
CREATE TABLE app_settings (
  id                          INTEGER PRIMARY KEY DEFAULT 1,
  half_life_days              REAL DEFAULT 7.0,
  notification_threshold      REAL DEFAULT 0.25,
  notifications_enabled       INTEGER DEFAULT 1,
  is_dark_mode                INTEGER DEFAULT 1,
  theme_palette               TEXT DEFAULT 'warm_stone',
  swipe_left_action           TEXT DEFAULT 'archive',
  swipe_right_action          TEXT DEFAULT 'read',
  domain_half_life_overrides  TEXT, -- Serialized JSON Map
  tag_half_life_overrides     TEXT  -- Serialized JSON Map
);
```

---

## ✦ Project Structure

```
link_decay_app/
├── lib/
│   ├── main.dart                    # Entry point — init + ProviderScope
│   ├── app.dart                     # MaterialApp + bottom nav shell
│   ├── app_theme.dart               # Theme palettes configuration
│   │
│   ├── data/
│   │   ├── database.dart            # Drift DB: tables, queries, streams
│   │   └── database.g.dart          # Generated Drift queries
│   │
│   ├── models/
│   │   └── link_status.dart         # Enum: inbox / read / archived
│   │
│   ├── providers/
│   │   └── providers.dart           # All Riverpod providers + actions
│   │
│   ├── services/
│   │   ├── metadata_service.dart    # Fetch title, description, images & favicon
│   │   ├── export_service.dart      # JSON & Netscape HTML import/export
│   │   ├── notification_service.dart # Daily staleness notifications
│   │   └── share_intent_service.dart # Android share sheet listener
│   │
│   ├── screens/
│   │   ├── inbox_screen.dart        # Main reading list with stats panel
│   │   ├── collections_screen.dart  # Folder grid & collection details
│   │   ├── archive_screen.dart      # Search + filter read/archived links
│   │   ├── settings_screen.dart     # Preferences & data tools
│   │   ├── link_detail_screen.dart  # Rich details, notes & quotes
│   │   └── custom_filter_creator.dart # Smart lists builder
│   │
│   ├── widgets/
│   │   ├── link_card.dart           # Dismissible card with customized gestures
│   │   ├── freshness_bar.dart       # Animated color-coded bar
│   │   ├── add_link_sheet.dart      # URL input & folder tag selection
│   │   ├── snooze_sheet.dart        # Snooze duration picker
│   │   ├── multi_select_bar.dart    # Selection action panel
│   │   ├── smart_list_bar.dart      # Custom filter preset chips
│   │   ├── stats_dashboard_panel.dart # Pull-down stats visual dashboard
│   │   └── collection_picker_sheet.dart # Move folder picker sheet
│   │
│   └── utils/
│       ├── constants.dart           # Colors, spacing, defaults
│       └── freshness.dart           # Decay math + helpers
│
├── android/
│   └── app/
│       ├── build.gradle.kts         # Core library desugaring enabled
│       └── src/main/
│           └── AndroidManifest.xml  # Share intent + notification perms
│
├── pubspec.yaml                     # All dependencies
└── README.md                        # This file
```

---

## ✦ Getting Started

### Prerequisites

```bash
flutter --version  # Requires 3.41.0+
dart --version     # Requires 3.11.0+
```

### Clone & Install

```bash
git clone https://github.com/yourname/link_decay_app.git
cd link_decay_app
flutter pub get
```

### Generate Code

Drift requires code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
# Run on connected device/emulator
flutter run
```

---

## ✦ Android Share Sheet Setup

ReadDecay registers itself as a handler for `text/plain` share intents. Once installed, you'll see **"ReadDecay"** appear in the Android share sheet from any app (Chrome, Firefox, Twitter, etc.).

The app handles two scenarios:
1. **App is open** — the shared URL is saved immediately
2. **App is closed** — the URL is captured when the app launches

---

## ✦ Notification Setup

On first launch, ReadDecay requests notification permission. If granted:
- A daily check runs at **9:00 AM local time**
- If any inbox links are below the freshness threshold, a notification is sent
- The notification survives device reboots via the `BOOT_COMPLETED` receiver

To adjust thresholds, go to **Settings → Notifications**.

---

## ✦ Design Language & Accent Themes

The UI is **clean, minimal, typographic** — inspired by neutral, high-quality, physical palettes:

| Theme Palette | Main Background | Card Accent | Description |
|---|---|---|---|
| **Warm Stone** (Default) | `#0E0D0C` | `#D9C3B0` | Earthy, warm organic tint |
| **Cold Slate** | `#0B0C0E` | `#A0B0C0` | Cool, modern architectural gray |
| **Forest Moss** | `#0B0E0C` | `#A8C3A0` | Soft botanical desaturated green |
| **Pitch Charcoal** | `#080808` | `#E0E0E0` | Deep monochrome contrast charcoal |

All custom components use uniform 16.0 margin alignment grids, 0.5px thin borders, and custom micro-animations (e.g. sliding navbar in selection mode, overscroll dashboard reveal).

---

## ✦ Development Notes

### Re-running Code Generation

Any change to table definitions in `lib/data/database.dart` requires a codegen re-run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Riverpod Architecture

All business logic lives in **providers**, not in widgets:

```
UI → ref.watch(provider)     # read reactive state
UI → ref.read(notifier)      # trigger actions
```

`LinkActionsNotifier` (accessed via `linkActionsProvider`) is the single point of truth for all mutations — insert, read, archive, snooze, delete, settings changes, folder management, and smart filters.

### Freshness is Never Stored

The freshness score is **computed at render time**, not persisted. This means:
- No migration headaches if the formula changes.
- Changing the half-life in settings retroactively re-scores all links.
- Snooze is stored as `snoozed_until` + cumulative `snoozed_seconds`.

### Debugging

```bash
# Static analysis
flutter analyze

# Run tests
flutter test
```

---

## ✦ License

```
MIT License

Copyright (c) 2026 ReadDecay Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

**Built with Flutter · Powered by Drift · Styled with Inter**

*Save the link. Beat the decay.*

</div>
