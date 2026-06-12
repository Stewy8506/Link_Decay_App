<div align="center">

```
██╗     ██████╗ ███╗   ██╗██╗  ██╗███████╗██╗  ██╗███████╗██╗     ███████╗
██║     ╚═██╔═╝ ████╗  ██║██║ ██╔╝██╔════╝██║  ██║██╔════╝██║     ██╔════╝
██║       ██║   ██╔██╗ ██║█████╔╝ ███████╗███████║█████╗  ██║     █████╗  
██║       ██║   ██║╚██╗██║██╔═██╗ ╚════██║██╔══██║██╔══╝  ██║     ██╔══╝  
███████╗██████╗ ██║ ╚████║██║  ██╗███████║██║  ██║███████╗███████╗██║     
╚══════╝╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     
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

> **LinkShelf** is a cross-device reading list manager with a twist — saved links have a **freshness score** that exponentially decays over time. The longer you wait, the staler they get. Inbox links sort dynamically, bubbling stale items to the top to demand your attention. Read them, snooze them, or watch them fade.
> 
> Available as a native **Mobile App (Android)**, native **Desktop Apps (macOS & Windows)**, and a **Browser Extension (Chrome & Safari)**.

</div>

---

## ✦ Core Product Philosophy

Most read-later apps treat your lists like an infinite warehouse — links pile up forever, sorted by date, never prompting action. **LinkShelf treats information like a perishable.** Every link has a shelf life. 

As a link ages:
- Its freshness score decays from `1.00` down to `0.00`.
- Its status bar accent shifts: `🟢 Fresh → 🟡 Fading → 🟠 Stale → 🔴 Critical`.
- Staler items rise to the top of the queue, creating visual priority.

---

## ✦ Key Features

- **Dynamic Color-Coded Status Bars**: Per-card freshness bars and numerical badges representing decay in real time.
- **Widescreen Responsive UI**: Automatic adaptive structures, transitioning from bottom tab-bars on mobile to persistent left sidebars on desktop screens.
- **Smart Lists Builder**: Create automated folders using custom rules like decay bounds, estimated read times, domains, or tags.
- **Browser Extension Popup**: Harnesses native JS Interop to query active browser tabs and auto-detect URLs.
- **Habit Diagnostics Drawer**: Overscroll-to-reveal panel with streaks tracking, saved/read velocity charts, and contribution calendars.
- **Import & Backup Tools**: Support for standard Netscape HTML bookmarks and JSON database backups with merge/overwrite strategies and client-side transaction rollbacks.

---

## ✦ Quickstart (3-Step Dev Setup)

### 1. Pre-flight Setup
Ensure your environment meets version requirements (Flutter `3.41.0+` · Dart `3.11.0+`), then clone the repository:
```bash
git clone https://github.com/Stewy8506/LinkShelf.git
cd LinkShelf
flutter pub get
```

### 2. Configure Credentials
Configure the client project settings using the FlutterFire CLI:
```bash
firebase login
flutterfire configure --platforms=android,macos,web
```

### 3. Run the App
```bash
flutter run -d macos    # Target Native macOS Desktop
flutter run -d chrome   # Target Web Sandbox Emulator
flutter run             # Target Connected Mobile Device
```

---

## ✦ Documentation Navigation Guide

Detailed specifications, build instructions, and design sheets are split into organized modules under `/docs`:

### [🏛️ Architecture Sheets](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/overview.md)
*   [Overview & Stack Flow](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/overview.md) — Structural layout details and layer blocks.
*   [The Freshness Engine](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/freshness-engine.md) — Mathematical formulation of decay curves and overrides.
*   [State Management Graph](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/state-management.md) — Riverpod provider streams and reactive score updates.
*   [Database Schemas](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/database-schema.md) — Firestore layout, document types, and namespaces.
*   [Authentication & Sync](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/sync-and-auth.md) — Silent logins, Google linking, and merging conflicts.
*   [Browser Extension JS Interop](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/extension-interop.md) — Web API bindings and conditional exports.
*   [Startup Migration System](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/architecture/migration-system.md) — Legacy Drift SQLite to Cloud Firestore porting.

### [📦 Product Features](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/inbox.md)
*   [Link Ingestion Inbox](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/inbox.md) — Open Graph scraping and dead link indicators.
*   [Collections Folders](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/collections.md) — Tactile stacked UI design and folder decay metrics.
*   [Custom Smart Lists](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/smart-lists.md) — Rule-based dynamic filters.
*   [Stats Dashboard Panel](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/stats-dashboard.md) — Habit grids and velocity charts.
*   [Snooze Pause Controls](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/snoozing.md) — Delay-freezing parameters and configuration.
*   [Backup & Restores](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/backup-restore.md) — JSON dumps, HTML parsing, and transaction rollbacks.
*   [Palettes & Typography](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/features/theming.md) — Design systems and typography options.

### [🔧 Compilation & Setups](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/local-development.md)
*   [Local Development Setup](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/local-development.md) — Packages installs and IDE configurations.
*   [Firebase Integration](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/firebase-setup.md) — Project provisioning and deploying security rules.
*   [Android Compilation](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/build-android.md) — Generating upload keys and AAB building.
*   [Desktop Compilation](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/build-desktop.md) — macOS & Windows runners size overrides.
*   [Extension Compilation](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/build-extension.md) — Web packaging and CSP compilation.
*   [Google Play Release Process](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/setup/release-process.md) — 20-tester rules and rollout tracks.

---

## ✦ Development Operations
*   [Product Roadmap](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/docs/roadmap.md) — Features milestones and version schedules.
*   [Contributing Guidelines](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/CONTRIBUTING.md) — Commit standards, branch structures, and PR rules.
*   [Changelog History](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/CHANGELOG.md) — Complete release logs following semantic tracking.

---

## ✦ License

LinkShelf is distributed under the [MIT License](LICENSE).
