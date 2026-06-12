# Changelog

All notable changes to **LinkShelf** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-06-12

This release transitions the application from a local-only database to a fully-synced Cloud Firestore backend, supporting cross-device synchronization and introducing a desktop widescreen view and browser extensions.

### Added
- **Cloud Firestore Synchronization**: Complete real-time sync across devices, replacing local-only databases.
- **Silent Anonymous Auth**: Seamless guest onboarding on first startup, generating a secure Firebase credentials session.
- **Google Account Linking**: Connect Google accounts in Settings to backup and sync your reading list.
- **Account Merge Resolution**: Interactive merge flows that copy offline guest bookmarks directly into the newly linked Google account.
- **Desktop Sidebar Navigation**: Adaptive left sidebar navigation layout for displays wider than 600px.
- **Browser Extension Popup View**: Manifest V3 compliant extension popup utilizing `dart:js_interop` to fetch active tab URLs automatically.
- **Smart Lists Builder**: Create custom rule-based folders filtering by tag, freshness ranges, read times, and domains.
- **Habit Tracker Panel**: Reveal metrics dashboard on Inbox overscroll (showing streaking trackers, charts, and heatmaps).

### Changed
- **Primary Data Store**: Migrated primary persistence from local SQLite (Drift) to Cloud Firestore.

### Deprecated
- **Local SQLite Storage**: Drift database files are deprecated and will be removed in subsequent updates after checking migration logs.

### Fixed
- **Swipe Gestures Handler**: Fixed visual lags in card swipe gesture customizer settings on Android devices.
- **Add-Link Normalizer**: Normalizes manual URL input (e.g. prepending `https://` if missing) before ingestion.

### Security
- **Path-Isolated Access**: Firestore security rules restrict all read and write queries to paths matching the user's authenticated `uid`.
