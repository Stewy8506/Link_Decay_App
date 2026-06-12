# State Management with Riverpod

LinkShelf relies on **Riverpod 2.x** to orchestrate application state. By decoupling state logic from UI widgets, the application maintains a reactive, unidirectional data flow. 

This document details the provider graph, the mechanics of dynamic score recalculations, and how writes trigger automatic view updates.

---

## ✦ The Reactive State Loop

Instead of querying Firestore on user action and manually updating state arrays, the UI subscribes to reactive streams. When a write occurs, Firestore emits a new snapshot which propagates down the provider graph:

```mermaid
sequenceDiagram
    participant UI as Flutter UI Component
    participant Provider as sortedFilteredInboxProvider
    participant Source as inboxLinksProvider (Stream)
    participant Firestore as Cloud Firestore
    participant Actions as linkActionsProvider (Notifier)

    UI->>Actions: saveLink("https://github.com")
    Actions->>Firestore: Writes new Link document
    Note over Firestore: Data changes; triggers update
    Firestore-->>Source: Emits updated List<Link>
    Source-->>Provider: Notifies of change
    Note over Provider: Recalculates freshness scores,<br/>applies text search and filters
    Provider-->>UI: Rebuilds widgets with new sorted list
```

---

## ✦ Key Providers Map

The state layer is categorized into three functional groups:

### 1. Database & Services Access
- `firestoreServiceProvider`: Exposes a singleton wrapper for Firestore operations.
- `authServiceProvider`: Exposes the Firebase Authentication gateway.
- `databaseProvider`: Exposes the legacy SQLite database connection strictly to aid startup migration tasks.

### 2. Stream Data Channels
- `userProvider`: Streams the current Firebase `User` session. When a user logs in or links an account, downstream providers update automatically.
- `settingsProvider`: Streams the user's `AppSetting` profile document.
- `inboxLinksProvider`: Streams the raw unsorted list of links matching `status == LinkStatus.inbox`.
- `archiveLinksProvider`: Streams the list of read/archived links.
- `collectionsProvider` & `customFiltersProvider`: Stream custom folder directories and Smart List rule-set templates.

### 3. Derived Computations & UI State
- `selectedLinkIdsProvider`: Maintains a `Set<String>` of IDs selected during bulk editing.
- `sortedFilteredInboxProvider`: The primary computed view model. It watches the raw link streams, global settings, search terms, and active filters, and returns a processed list of `Link` models sorted dynamically.

---

## ✦ Real-Time Decay Scoring in Streams

To represent freshness decay accurately without writing to the cloud every minute, **all score computations are computed in memory** inside `sortedFilteredInboxProvider`.

When the provider evaluates a list of links:
1. It reads the baseline settings (`halfLifeDaysProvider`, `decayCurveTypeProvider`).
2. It fetches customized override rules (`domainHalfLifeOverridesProvider`, `tagHalfLifeOverridesProvider`).
3. For each link, it computes the freshness score based on the link's `createdAt` timestamp, active snoozes, and calculated half-life.
4. It filters out items that do not fit the search text or the active folder constraint.
5. It sorts the collection (e.g. by descending staleness) and returns it to the UI.

Since this happens instantly in memory, the UI stays in sync, and user interactions (like typing a search term or switching a folder) occur instantly with 0ms database latency.
