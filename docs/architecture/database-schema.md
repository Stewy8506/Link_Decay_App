# Database Schema and Firestore Layout

LinkShelf uses **Cloud Firestore** as its primary system of record. Every user has a sandboxed document directory matching their unique Firebase Authentication `uid`.

This document describes the schema collections, individual fields, types, and database layout.

---

## ✦ Sub-collection Namespace Structure

The database namespaces documents hierarchically:

```
/users/{userId}/
  ├── settings/
  │     └── app_settings  <--- Config Document (AppSetting)
  │
  ├── links/
  │     └── {linkId}      <--- Document (Link)
  │
  ├── collections/
  │     └── {folderId}    <--- Document (Collection)
  │
  ├── custom_filters/
  │     └── {filterId}    <--- Document (CustomFilter)
  │
  └── highlights/
        └── {highlightId} <--- Document (LinkHighlight)
```

---

## ✦ Collection Schemas

### 1. Links `/users/{userId}/links/{linkId}`
Represents individual saved articles or websites.

| Field | Type | Description |
|---|---|---|
| `url` | `String` | The normalized, fully-qualified URL. |
| `title` | `String?` | Scraped title metadata (or custom user override). |
| `domain` | `String` | Extracted hostname domain. |
| `faviconUrl` | `String?` | Cached link to the favicon icon. |
| `createdAt` | `Timestamp` | Instant the URL was saved. |
| `snoozedUntil` | `Timestamp?` | Timestamp until which decay scoring is paused. |
| `status` | `String` | Status state enum representation (`inbox`, `read`, `archived`). |
| `tags` | `String` | Comma-separated list of assigned tag strings. |
| `snoozedSeconds`| `Int` | Cumulative duration (seconds) spent in snoozed states. |
| `collectionId` | `String?` | Reference ID of the folder collection it belongs to. |
| `notes` | `String?` | Markdown-supported personal reading notes. |
| `ogImageUrl` | `String?` | Background preview image link resolved from metadata. |
| `estimatedReadMinutes` | `Int?` | Estimated reading duration. |
| `readAt` | `Timestamp?` | Instant marked as read. |
| `archivedAt` | `Timestamp?` | Instant sent to the archive. |
| `customHalfLifeDays` | `Double?` | Specific decay override rate (1 to 30 days). |
| `isDead` | `Boolean` | Flag indicating broken/unreachable targets (e.g., 404). |

### 2. Collections `/users/{userId}/collections/{collectionId}`
Represents folder directories to categorize saved links.

| Field | Type | Description |
|---|---|---|
| `name` | `String` | Custom name of the folder collection. |
| `emoji` | `String?` | Visual identifier emoji. |
| `createdAt` | `Timestamp` | Instant the folder was created. |
| `sortOrder` | `Int` | Manual visual sorting rank. |

### 3. Custom Filters (Smart Lists) `/users/{userId}/custom_filters/{filterId}`
Represents dynamic rules to build smart inbox perspectives.

| Field | Type | Description |
|---|---|---|
| `name` | `String` | Custom name of the filter. |
| `icon` | `String` | Reference name of the visual icon (default: `list`). |
| `minFreshness` | `Double?` | Lower freshness boundary. |
| `maxFreshness` | `Double?` | Upper freshness boundary. |
| `tags` | `String?` | Comma-separated tags required to match. |
| `collections` | `String?` | Comma-separated collection ID scope constraints. |
| `domains` | `String?` | Comma-separated domain string filter checks. |
| `minReadTime` | `Int?` | Minimum estimated read time. |
| `maxReadTime` | `Int?` | Maximum estimated read time. |
| `snoozeFilter` | `String?` | Snooze view configuration (`exclude_snoozed`, `only_snoozed`, or `null`). |
| `sortField` | `String` | Default sorting order field identifier. |

### 4. Link Highlights `/users/{userId}/highlights/{highlightId}`
Represents highlights cropped from article contents.

| Field | Type | Description |
|---|---|---|
| `linkId` | `String` | Target link document reference. |
| `content` | `String` | Highlighted text quote snippet. |
| `createdAt` | `Timestamp` | Instant the quote was created. |

### 5. Settings `/users/{userId}/settings/app_settings`
A single document holding configuration overrides.

| Field | Type | Description |
|---|---|---|
| `halfLifeDays` | `Double` | Base decay rate (default: `7.0`). |
| `notificationThreshold` | `Double` | Freshness level that triggers alerts (default: `0.25`). |
| `notificationsEnabled` | `Boolean` | Flag for staleness alerts. |
| `isDarkMode` | `Boolean` | General theme preference. |
| `themePalette` | `String` | UI color palette name choice. |
| `swipeLeftAction` | `String` | Configured gesture handler action (e.g. `archive`). |
| `swipeRightAction`| `String` | Configured gesture handler action (e.g. `read`). |
| `domainHalfLifeOverrides` | `String?` | Serialized JSON map of custom domain half-lives. |
| `tagHalfLifeOverrides` | `String?` | Serialized JSON map of custom tag half-lives. |
| `dailyReadingGoal` | `Int` | Target count of links to read per day. |
| `snoozePresets` | `String` | Serialized JSON array of hour offsets (default: `[1, 3, 7]`). |
| `fontFamily` | `String` | Selected typography family name. |
| `customAccentColor` | `String?` | User-defined custom accent hex. |
| `customBgColor` | `String?` | User-defined custom background hex. |
| `decayCurveType` | `String` | Math equation selection (`exponential` or `linear`). |

---

## ✦ Indexing and Performance Considerations

LinkShelf utilizes client-side sorting inside Riverpod providers for the majority of view calculations, reducing the need for composite indexes on Cloud Firestore:
- **Simple indexes**: Single-field filters query `status` on the `/links/` collection to feed the inbox streams.
- **Client-Side Processing**: Complex evaluations (e.g. domain checks, tags intersection, decay scoring, dynamic sorting) are handled by client threads, minimizing query-overhead charges and index configuration dependencies.
