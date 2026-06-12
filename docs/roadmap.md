# LinkShelf Product Roadmap

This document outlines the short-term, medium-term, and long-term goals for the development of **LinkShelf**.

---

## ✦ Short-Term Goals (v1.1.0)
*Focus: UX polishing, tag management, and platform feature expansions.*

- [ ] **Tag Management Panel**: A dedicated Settings dashboard to list all tags, rename them globally, delete unused tags, and configure tag-specific decay rates easily.
- [ ] **Custom Notification Times**: Let users configure exactly when they receive daily staleness alerts (default: 9:00 AM local time).
- [ ] **Multi-Select Tag Manager**: Expand multi-select actions to allow assigning or removing multiple tags at once.

---

## ✦ Medium-Term Goals (v1.2.0)
*Focus: Data performance, advanced parsing, and offline improvements.*

- [ ] **Offline Sync Queue**: Improve offline support by caching writes locally and batch-syncing them with Firestore once a connection is restored.
- [ ] **Reader Mode Parser**: A scraper service to strip ads and extract clean article text, saving readability templates directly to Firestore.
- [ ] **Dead Link Auto-Archiver**: A setting to automatically move dead links (e.g. 404 pages) to the archive after a validation check.

---

## ✦ Long-Term Goals (v2.0.0)
*Focus: AI categorization, shared collections, and dashboard expansions.*

- [ ] **AI Ingestion Auto-Tagger**: Integrate local on-device LLMs (e.g., Gemini Nano) to analyze page titles/descriptions and suggest relevant tags.
- [ ] **Shared Family Shelves**: Shared folders allowing multiple users to curate, discuss, and read collections together.
- [ ] **Web Dashboard**: Expand the browser extension into a full-page web app to review links on any device without compiling local desktop builds.
