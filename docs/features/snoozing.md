# Link Snoozing and Decay Freezing

For links that require attention later (e.g. a long video or reference document for next week), LinkShelf provides a **Snooze** feature. Snoozing freezes the decay calculations for a user-specified duration, keeping the link's score from dropping.

---

## ✦ System Intent and Behavior

Snoozing acts as a pause button for information decay:
- **State Indicator**: Snoozed links display a `⏸ Snoozed until [Date]` badge and shift to a neutral color styling in the inbox list.
- **Urgency Suppression**: While active, the link's freshness score is frozen. In default inbox listings (sorted by ascending freshness), the link drops lower in priority, clearing space for staler links that need immediate attention.
- **Expiration and Resume**: Once the snooze time passes, the link's decay resumes naturally from its frozen level, and the card changes back to its active color band.

---

## ✦ Configuration and Customization

```
┌──────────────────────────────────────────────────────────┐
│                      Snooze Settings                     │
├──────────────────────────────────────────────────────────┤
│ ⚙️ Presets (JSON List)  | e.g., [2, 12, 72] hours        │
│ 📝 Cumulative Logs     | Tracks total snoozed seconds.   │
│ 🔄 Stacking Support     | Successive snoozes stack.       │
└──────────────────────────────────────────────────────────┘
```

- **Presets**: Users can customize their snooze duration buttons in Settings as a JSON array representing hour offsets.
- **Stacking Snoozes**: Re-snoozing an already snoozed link adds the new duration to the existing timeline, updating `snoozedUntil` and accumulating the total freeze time in the `snoozedSeconds` metric.
- **Static Persistence**: Unlike standard snooze mechanisms, LinkShelf does not run background threads or timed triggers to update snoozed files. The status is resolved dynamically in the state layer by comparing the link's `snoozedUntil` field with the device's current system time, keeping the database load light.
