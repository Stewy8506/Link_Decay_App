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

> **ReadDecay** is a local-first reading list manager with a twist — every link you save has a **freshness score** that exponentially decays over time. The longer you wait, the staler it gets. Links you haven't read sort to the top, glowing red, demanding your attention. Read them, snooze them, or watch them fade.

<br/>

</div>

---

## ✦ The Concept

Most read-later apps treat your reading list like a warehouse — links pile up forever, sorted by date, never asking you to act. **ReadDecay treats your reading list like a perishable.** Every link has a shelf life.

The core mechanic is **exponential decay**:

```
freshness(t) = 0.5 ^ (effectiveAge / halfLife)
```

A link saved today scores `1.0`. After one half-life (default: 7 days), it scores `0.5`. After two, `0.25`. The inbox sorts by ascending freshness — **the most stale links rise to the top**, creating urgency through visual pressure. A color-coded bar shifts from `green → yellow → red` as time passes.

It's gamified procrastination therapy.

---

## ✦ Feature Set

### 📥 Inbox
- **Automatic metadata fetching** — saves a URL and immediately fetches the page title and favicon in the background (with Open Graph support and Google S2 favicon fallback)
- **Freshness-sorted list** — most stale links always surface at the top
- **Per-card freshness bar** — animated, color-coded `green → yellow → red`
- **Numeric score badge** — exact freshness value (0.00 – 1.00) on each card
- **Age label** — human-readable ("just now", "3 days ago", "2 wks ago")
- **Domain + favicon** — extracted from URL, lettermark fallback if favicon fails
- **Tag chips** — inline tag display on each card (up to 3 visible)
- **Half-life info bar** — shows current decay rate at the top of the list
- **Link count badge** — live count of inbox items in the app bar

### 👆 Gestures
| Gesture | Action |
|---|---|
| **Tap** | Open link in external browser |
| **Swipe right →** | Mark as read (green confirmation + Undo) |
| **Swipe left ←** | Archive link (blue confirmation + Undo) |
| **Long press** | Open snooze sheet |

### 😴 Snooze
- **1 day** — back tomorrow
- **3 days** — back in 3 days
- **1 week** — back next week
- Decay **pauses** for the entire snooze duration (effective age freezes)
- Snoozed items show a `⏸ Snoozed until Jun 18` badge on the card
- Snooze history accumulates — multiple snoozes stack correctly

### ➕ Add Links
- **FAB / "+" button** in the app bar
- Paste any URL manually into the add sheet
- **Paste from clipboard** button — one tap
- Validates and auto-normalizes URLs (adds `https://` if missing)
- Shows animated loading state while fetching metadata
- **Share sheet** (Android) — share any URL from Chrome, Safari, Twitter, etc. directly into ReadDecay

### 📂 Archive
- All read and archived links in one searchable screen
- **Full-text search** — filters by title, domain, and tags live as you type
- **Status filter chips** — All / Read / Archived
- **Tag filter chips** — dynamically generated from all tags in your library
- Result count indicator
- Tap any archived link to reopen in browser
- Status dot (🟢 Read · 🔵 Archived) on each card

### ⚙️ Settings
| Setting | Default | Range |
|---|---|---|
| Half-life | 7 days | 1 – 30 days |
| Notification threshold | 25% freshness | 5% – 90% |
| Daily notifications | Enabled | On / Off |
| Dark mode | Dark | Dark / Light |

### 🔔 Notifications
- **Daily at 9 AM** local time — checks for stale links below threshold
- Smart batching: "3 saved links are getting stale — time to catch up!"
- Permission requested at runtime (Android 13+, iOS)
- Persists across device reboots (BOOT_COMPLETED receiver)
- Cancels automatically when no stale links exist

---

## ✦ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer                            │
│  InboxScreen  ArchiveScreen  SettingsScreen             │
│  LinkCard  AddLinkSheet  SnoozeSheet  FreshnessBar      │
└─────────────────────┬───────────────────────────────────┘
                      │ watches / reads providers
┌─────────────────────▼───────────────────────────────────┐
│                 State Layer (Riverpod 2.x)               │
│  inboxLinksProvider    → StreamProvider<List<Link>>      │
│  archiveLinksProvider  → StreamProvider<List<Link>>      │
│  settingsProvider      → StreamProvider<AppSetting?>     │
│  halfLifeDaysProvider  → Provider<double>               │
│  linkActionsProvider   → NotifierProvider               │
│  filteredArchiveLinks  → Provider (search + filter)     │
│  allTagsProvider       → Provider<List<String>>         │
└─────────────────────┬───────────────────────────────────┘
                      │ reads / writes
┌─────────────────────▼───────────────────────────────────┐
│                  Data Layer                             │
│  AppDatabase (Drift + SQLite)                          │
│    Links table        AppSettings table                 │
│  MetadataService      NotificationService              │
│  ShareIntentService                                    │
└─────────────────────────────────────────────────────────┘
```

### Freshness Decay Model

```dart
// Effective age accounts for total time spent snoozed
score = pow(0.5, effectiveAgeDays / halfLifeDays)

// If currently snoozed, remaining snooze time is subtracted
// from effective age — decay is completely paused
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
| **Networking** | `http` · `html` (HTML parsing) |
| **Notifications** | `flutter_local_notifications` v18 + `timezone` |
| **Share** | `receive_sharing_intent` |
| **URL Launcher** | `url_launcher` |
| **Favicon** | Google S2 Favicon API (`s2.favicons?domain=...&sz=64`) |

### Database Schema

```sql
-- Links table
CREATE TABLE links (
  id            TEXT PRIMARY KEY,
  url           TEXT NOT NULL,
  title         TEXT,
  domain        TEXT NOT NULL,
  favicon_url   TEXT,
  created_at    INTEGER NOT NULL,  -- Unix epoch ms
  snoozed_until INTEGER,           -- NULL if not snoozed
  status        TEXT NOT NULL,     -- 'inbox' | 'read' | 'archived'
  tags          TEXT DEFAULT '',   -- Comma-separated
  snoozed_seconds INTEGER DEFAULT 0  -- Cumulative snooze duration
);

-- App settings (single-row, id = 1)
CREATE TABLE app_settings (
  id                        INTEGER PRIMARY KEY DEFAULT 1,
  half_life_days            REAL DEFAULT 7.0,
  notification_threshold    REAL DEFAULT 0.25,
  notifications_enabled     INTEGER DEFAULT 1,
  is_dark_mode              INTEGER DEFAULT 1
);
```

---

## ✦ Project Structure

```
link_decay_app/
├── lib/
│   ├── main.dart                    # Entry point — init + ProviderScope
│   ├── app.dart                     # MaterialApp + bottom nav shell
│   ├── app_theme.dart               # Dark & light Material 3 themes
│   │
│   ├── data/
│   │   ├── database.dart            # Drift DB: tables, queries, streams
│   │   └── database.g.dart          # Generated (do not edit)
│   │
│   ├── models/
│   │   └── link_status.dart         # Enum: inbox / read / archived
│   │
│   ├── providers/
│   │   └── providers.dart           # All Riverpod providers + actions
│   │
│   ├── services/
│   │   ├── metadata_service.dart    # Fetch title + favicon from URL
│   │   ├── notification_service.dart # Daily staleness notifications
│   │   └── share_intent_service.dart # Android share sheet listener
│   │
│   ├── screens/
│   │   ├── inbox_screen.dart        # Main reading list
│   │   ├── archive_screen.dart      # Search + filter read/archived links
│   │   └── settings_screen.dart     # Preferences + freshness legend
│   │
│   ├── widgets/
│   │   ├── link_card.dart           # Dismissible card with all gestures
│   │   ├── freshness_bar.dart       # Animated color-coded bar + dot
│   │   ├── add_link_sheet.dart      # URL input bottom sheet
│   │   └── snooze_sheet.dart        # Snooze duration picker
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

Drift requires code generation (run this once, and again if you modify `database.dart`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
# Android (recommended — full feature set)
flutter run

# Run on a specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## ✦ Android Share Sheet Setup

ReadDecay registers itself as a handler for `text/plain` share intents. Once installed, you'll see **"ReadDecay"** appear in the Android share sheet from any app (Chrome, Firefox, Twitter, etc.).

The app handles two scenarios:
1. **App is open** — the shared URL is saved immediately
2. **App is closed** — the URL is captured when the app launches

---

## ✦ Notification Setup

On first launch, ReadDecay requests notification permission (Android 13+ / iOS). If granted:
- A daily check runs at **9:00 AM local time**
- If any inbox links are below the freshness threshold, a notification is sent
- The notification survives device reboots via the `BOOT_COMPLETED` receiver

To adjust thresholds, go to **Settings → Notifications**.

---

## ✦ Design Language

The UI is **clean, minimal, typographic** — inspired by the aesthetics of Claude and Gemini:

| Token | Value |
|---|---|
| Background | `#0A0A0B` (near-black) |
| Surface | `#141416` |
| Card | `#1C1C1F` |
| Border | `#2A2A2F` (0.5px) |
| Accent | `#E8927C` (warm salmon) |
| Snooze | `#8B5CF6` (soft violet) |
| Font | Inter (Google Fonts) |
| Motion | `Curves.easeOutCubic`, 250–400ms |
| Corner radius | 12px cards, 16px sheets, 24px FAB |

The freshness bar is the only element with strong color — everything else stays monochrome, so the bar commands full attention.

---

## ✦ Planned Features (Future)

- [ ] **Supabase sync** — optional multi-device sync, login via OAuth
- [ ] **iOS share extension** — Xcode target for share sheet on iOS
- [ ] **Tags editor** — add/remove/rename tags on each link
- [ ] **Import from Pocket / Instapaper** — migrate existing reading lists
- [ ] **Widgets** — Android home screen widget showing top stale link
- [ ] **Web scraping fallback** — Readability-style content extraction
- [ ] **Custom snooze** — date picker for arbitrary snooze end date
- [ ] **Bulk actions** — select multiple cards, mark all as read
- [ ] **Dark/light auto** — follow system setting
- [ ] **Export** — CSV / JSON backup

---

## ✦ Development Notes

### Re-running Code Generation

Any change to `lib/data/database.dart` requires a codegen re-run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Riverpod Architecture

All business logic lives in **providers**, not in widgets:

```
UI → ref.watch(provider)     # read reactive state
UI → ref.read(notifier)      # trigger actions
```

`LinkActionsNotifier` is the single point of truth for all mutations — insert, read, archive, snooze, delete, and settings updates all go through it.

### Freshness is Never Stored

The freshness score is **computed at render time**, not persisted. This means:
- No migration headaches if the formula changes
- Changing the half-life in settings retroactively re-scores all links
- Snooze is stored as `snoozed_until` + cumulative `snoozed_seconds`

### Debugging

```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated
```

---

## ✦ Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit with conventional commits: `git commit -m "feat: add tag autocomplete"`
4. Push: `git push origin feat/your-feature`
5. Open a PR

Please run `flutter analyze` and `flutter test` before submitting.

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
