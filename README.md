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
[![Cloud Firestore](https://img.shields.io/badge/Cloud_Firestore-Database-FFCA28?style=flat-square&logo=firebase)](https://firebase.google.com)
[![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-Sync-FFCA28?style=flat-square&logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=flat-square)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Web%20Extension-3DDC84?style=flat-square)](https://flutter.dev)

<br/>

> **LinkShelf** is a cloud-synced reading list manager with a twist — every link you save has a **freshness score** that exponentially decays over time. The longer you wait, the staler it gets. Links you haven't read sort to the top, glowing red, demanding your attention. Read them, snooze them, organize them, or watch them fade.
> 
> Now available as a **native Mobile App (Android)**, **native Desktop Apps (macOS & Windows)**, and a **Browser Extension (Chrome & Safari)**!

<br/>

</div>

---

## ✦ The Concept

Most read-later apps treat your reading list like an infinite warehouse — links pile up forever, sorted by date, never asking you to act. **LinkShelf treats your reading list like a perishable.** Every link has a shelf life.

The core mechanic is **exponential decay**:

```
freshness(t) = 0.5 ^ (effectiveAge / halfLife)
```

A link saved today scores `1.0`. After one half-life (default: 7 days), it scores `0.5`. After two, `0.25`. The inbox sorts by ascending freshness — **the most stale links rise to the top**, creating urgency through visual pressure. A color-coded bar shifts from `green → yellow → orange → red` as time passes.

It's gamified procrastination therapy.

---

## ✦ Implemented Features

### ☁️ Cloud Sync & Database Migration
- **Transparent Silent Anonymous Authentication** — On first boot, the app silently authenticates users using Firebase Anonymous Sign-In so they can use the app instantly without registering.
- **Cross-Device Sync** — Link your database to a Google account from Settings to automatically sync and access your reading lists across devices.
- **Conflict Merge Resolution** — Tapping "Link Google Account" when the Google account is already linked to another profile prompts an "Account Sync Conflict" dialog. If approved, the app reads offline links saved in the current anonymous session into memory, signs in to the Google account, and copies (merges) the links directly to the Google account.
- **Legacy SQLite Migration** — Automatically detects legacy SQLite (Drift) database records on startup, performs a batch migration to Cloud Firestore under the user's `uid`, and clean up Drift resources.
- **Path-Isolated Security Rules** — Enforces strict data ownership where users can only read or write under `/users/{userId}/` matching their own authenticated `uid`.

### 🖥️ Desktop Widescreen Layout (Widescreen Mode)
- **Left Sidebar Navigation (`_DesktopSidebar`)** — When window width is >600px, LinkShelf automatically transforms from mobile bottom nav to a widescreen layout featuring a persistent left sidebar with bold branding and interactive highlights.
- **Widescreen Centered Dialogs** — Pushes `AddLinkSheet` inside a beautifully bounded, rounded widescreen Dialog (450px) instead of sliding up from the bottom of the screen.
- **Dynamic Columns Grid Math** — Calculates grid dimensions dynamically on the Folders screen to lay out folders appropriately depending on display size.
- **Dynamic Spacings** — Adjusts bottom scroll list spacing to automatically shrink from mobile pill padding (100–200px) down to standard desktop padding (40px) when the bottom floating navbar collapses.
- **Fluid Layout Resizing** — Narrowing the desktop app below 600px automatically transitions the UI seamlessly back into the compact phone layout.

### 🌐 Browser Extension Popup (Extension Mode)
- **Manifest V3 Compliant** — Extension architecture compiles to comply with Manifest V3 and strict Content Security Policies (CSP).
- **Tab Auto-Detection** — Harnesses a custom JS Interop service (`chrome.tabs.query`) to parse the active browser tab's URL automatically and populate the ingestion field instantly when the popup opens.
- **Fixed Extension Viewport** — Configured viewport dimensions (400x600px) to render the app's phone layout natively inside Chrome and Safari toolbar dropdown panels.

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
- **Dead link indicator** — Warns you about dead or unreachable pages with a `☠️ DEAD LINK` banner.

### 📂 Collections & Folder System
- **Folders Grid View** — Dedicated collections screen to group and organize links with custom names, emoji icons, active link counts, and **Average Freshness** scores calculated dynamically.
- **Tactile Card Stack Design** — Visual grid layout styling each folder as a physical directory tab with layered nested cards.
- **Spring Scale Animations** — Grid items feature dynamic haptic feedback and custom spring micro-scaling on tap.
- **Folders Dashboard** — Integrated overview metrics displaying total folder count, percentage of links organized, and general decay average.
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
- **28-Day Reading Heatmap Grid** — Contribution calendar visualization displaying daily reading frequency and progress over a 4-week window.
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
- **Customizable Snooze Presets** — Pause link decay using custom duration offsets (e.g. 2 hours, 12 hours, 3 days, 1 month) edited directly in settings.
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
- **JSON Backup** — Export and share a full database JSON backup. Import JSON backups with choice of *Merge* (keep local links) or *Overwrite* (purge tables first) restore strategies. Features transactional-like client-side rollbacks to protect database integrity on parsing errors.

### ⚙️ Preferences & Health Tools
- **Decay Curve Profiler** — Toggle between **Exponential** and **Linear** decay algorithms, dynamically recalculating and rendering freshness scores across all screens.
- **Link Health Check Scanner** — Background scanning utility to check saved inbox URLs for broken links (404, 5xx, or network issues), flagging offline pages.
- **Dead Link Warnings** — Unreachable or dead links are highlighted in the inbox list with a customized skull warning badge (`☠️ DEAD LINK`).
- **Domain & Tag Lifespan Overrides** — Define custom decay rates (half-life in days) for entire websites (e.g. `youtube.com`) or tags (e.g. `#news`) directly inside Settings.
- **Configurable Daily Reading Goal** — Set custom targets (e.g., read 3 links per day) to gauge reading consistency in the streak dashboard.
- **Notification Alert Threshold** — Tailor when notifications are triggered based on exact freshness percentage limits.

### 👆 Gestures Customizer
- Configure what **Swipe Left** and **Swipe Right** gestures do on link cards directly from settings (`None`, `Read`, `Archive`, `Snooze`, `Folder Picker`, or `Delete`).

### 🎨 Appearance & Themes
- Toggle light and dark modes.
- Select among four minimalist, neutral theme palettes: **Warm Stone** (Default), **Cold Slate**, **Forest Moss**, and **Pitch Charcoal**.
- **Infinite Theme Customizer** — Define your own custom accent and background colors directly using a hex color input card.
- **Typography Selector** — Choose between four distinctive typefaces (**Inter**, **Outfit**, **Playfair Display**, and **JetBrains Mono**) to dynamically style every single component and page throughout the app.

---

## ✦ Project Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer                            │
│  InboxScreen       CollectionsScreen  SettingsScreen    │
│  LinkDetailScreen  CustomFilterCreatorScreen            │
│  LinkCard          _DesktopSidebar    _FloatingPillNavBar│
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
│  Cloud Firestore (Primary Storage)                      │
│    `/users/{uid}/links/{linkId}`                        │
│    `/users/{uid}/collections/{collectionId}`            │
│    `/users/{uid}/custom_filters/{filterId}`             │
│    `/users/{uid}/settings/app_settings`                 │
│  Drift SQLite (Legacy database used for migration only)  │
│  AuthService            FirestoreService                │
│  MigrationService       MetadataService                 │
│  ExportService          NotificationService             │
│  ShareIntentService     ExtensionService (Interop Web)  │
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
| **Platforms** | Android, macOS (native Cocoa), Windows (native Win32), Web (Chrome & Safari extensions) |
| **Authentication** | Firebase Auth (Anonymous & Google Sign-In) |
| **Database** | Cloud Firestore (Primary) & Drift SQLite (Legacy migration helper) |
| **State** | [Riverpod](https://riverpod.dev) 2.x |
| **Fonts** | [Inter](https://rsms.me/inter/) via `google_fonts` |
| **Networking** | `http` · `html` (HTML scraping) |
| **JS Interop** | `dart:js_interop` & `dart:js_interop_unsafe` (Chrome tab query interfaces) |
| **Notifications** | `flutter_local_notifications` v18 + `timezone` |
| **Share** | `receive_sharing_intent` · `share_plus` |
| **File Picker** | `file_picker` (JSON / HTML imports) |
| **URL Launcher** | `url_launcher` |
| **Favicon** | Google S2 Favicon API (`s2.favicons?domain=...&sz=64`) |

---

## ✦ Project Structure

```
link_decay_app/
├── lib/
│   ├── main.dart                    # Entry point — initializes Firebase + runs Migration checks
│   ├── app.dart                     # MaterialApp + bottom nav / desktop shell
│   ├── app_theme.dart               # Theme palettes configuration
│   ├── firebase_options.dart        # Auto-generated FlutterFire options
│   │
│   ├── data/
│   │   ├── database.dart            # Drift DB: Legacy SQLite tables, queries, streams
│   │   └── database.g.dart          # Generated Drift queries
│   │
│   ├── models/
│   │   ├── models.dart              # Firestore-mapped domain models (Link, Collection, etc.)
│   │   └── link_status.dart         # Enum: inbox / read / archived
│   │
│   ├── providers/
│   │   └── providers.dart           # All Riverpod providers + Firestore actions notifier
│   │
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth: silent anonymous sign-in, Google link & switch auth
│   │   ├── firestore_service.dart   # Scoped user collection CRUD actions and document streams
│   │   ├── migration_service.dart   # Port SQLite data to Firestore under active uid
│   │   ├── metadata_service.dart    # Fetch title, description, images & favicon
│   │   ├── export_service.dart      # JSON & HTML export/import with rollback simulation
│   │   ├── notification_service.dart # Daily staleness notifications
│   │   ├── share_intent_service.dart # Android share sheet listener
│   │   ├── extension_service.dart   # Main conditional exporter for interop
│   │   ├── extension_service_stub.dart # Native targets stub fallback
│   │   └── extension_service_web.dart # Web-specific JS interop implementation
│   │
│   ├── screens/
│   │   ├── inbox_screen.dart        # Main reading list with stats panel
│   │   ├── collections_screen.dart  # Folder grid & collection details
│   │   ├── archive_screen.dart      # Search + filter read/archived links
│   │   ├── settings_screen.dart     # Sync options, preferences & data tools
│   │   ├── link_detail_screen.dart  # Rich details, notes & quotes
│   │   └── custom_filter_creator.dart # Smart lists builder
│   │
│   └── widgets/
│       ├── link_card.dart           # Dismissible card with customized gestures
│       ├── freshness_bar.dart       # Animated color-coded bar
│       ├── add_link_sheet.dart      # URL input & folder tag selection
│       ├── snooze_sheet.dart        # Snooze duration picker
│       ├── multi_select_bar.dart    # Selection action panel
│       ├── smart_list_bar.dart      # Custom filter preset chips
│       ├── stats_dashboard_panel.dart # Pull-down stats visual dashboard
│       └── collection_picker_sheet.dart # Move folder picker sheet
│
├── android/                         # Android native runner
├── macos/                           # macOS native runner (customized window size)
├── windows/                         # Windows native runner (customized size & title)
├── web/                             # Web target & Chrome/Safari extension configurations
│   ├── manifest.json                # Extension Manifest V3 configuration
│   └── index.html                   # Extension viewport and layout configs
│
├── firestore.rules                  # Scoped path-isolated Firebase security rules
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

### Configure Firebase

Firebase requires credentials to be configured via the FlutterFire CLI:

1. Log in to Firebase CLI:
   ```bash
   firebase login
   ```
2. Configure platforms:
   ```bash
   flutterfire configure --platforms=android,macos,web
   ```

### Run on Platforms

```bash
# Run on connected Android device/emulator
flutter run

# Run on macOS native desktop
flutter run -d macos

# Run on Windows native desktop (fallback database)
flutter run -d windows
```

### Build Browser Extension (Web)

To build the Chrome / Safari extension bundle:

```bash
flutter build web --web-renderer html --csp
```

Load the compiled `build/web` folder into Chrome as an **unpacked extension**:
1. Open Chrome and navigate to `chrome://extensions/`.
2. Enable **Developer mode** toggle in the top-right.
3. Click **Load unpacked** in the top-left and select the `build/web` directory.

---

## ✦ Notification Setup

On first launch, LinkShelf requests notification permission on supported platforms. If granted:
- A daily check runs at **9:00 AM local time**
- If any inbox links are below the freshness threshold, a notification is sent
- The notification survives device reboots via the `BOOT_COMPLETED` receiver (on Android)

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

## ✦ License

```
MIT License

Copyright (c) 2026 LinkShelf Contributors

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

**Built with Flutter · Powered by Firebase Cloud Firestore · Styled with Inter**

*Save the link. Beat the decay.*

</div>
