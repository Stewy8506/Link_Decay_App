# Smart Lists (Custom Filter Builder)

**Smart Lists** are dynamic, rule-based inbox perspectives. Instead of forcing you to organize links manually, Smart Lists let you build automated filters using specific rules like reading time constraints, decay status, or target domains.

---

## ✦ Filter Parameters and Rules

The `CustomFilter` model defines rules that are checked against the active link stream in memory:

```
┌──────────────────────────────────────────────────────────┐
│                   Custom Filter Options                  │
├──────────────────────────────────────────────────────────┤
│ 🏷️ Name & Icon Emoji                                     │
│ 🟢 Freshness Bounds    (e.g., 0.0 to 0.5 for stale only) │
│ ⏳ Read Time Bounds    (e.g., Min 1 min / Max 5 mins)    │
│ 🏷️ Tag Scope           (e.g., Match tags 'Dev' or 'Code')│
│ 📂 Folders Scope       (e.g., Search specific folders)   │
│ 🌐 Domain Scope        (e.g., Only show medium.com)      │
│ 😴 Snooze State        (Exclude, Include, Only)          │
│ ↕️ Sort Order Override (Newest, Title, Est Read Time)    │
└──────────────────────────────────────────────────────────┘
```

---

## ✦ System Resolution and Execution

Because Firestore does not support complex, multi-variable queries without expensive, pre-calculated indexes, Smart Lists are evaluated **on the client client-side** inside the Riverpod state layer (`sortedFilteredInboxProvider`):

1. **Stream Fetch**: The application streams the raw user list from Firestore.
2. **Dynamic Evaluation**: The list filters down by checking the user's active custom rules:
   - **Read Time Match**: Checks if the link's `estimatedReadMinutes` falls between `minReadTime` and `maxReadTime`.
   - **Snooze check**: Excludes or includes elements depending on whether `snoozedUntil` is active.
   - **Decay score filter**: Checks if the dynamic, calculated freshness score falls within the filter's boundaries.
3. **Sort Application**: The filter's custom sort order (e.g., `title_asc`, `read_time_asc`) overrides the default inbox sorting rule.
4. **UI Update**: The list is updated in real time, keeping rendering times under 16ms even during text queries on large feeds.
