# Stats Dashboard & Habit Tracker

To motivate users to tackle their reading backlog, LinkShelf features an interactive, pull-down **Stats Dashboard**. This panel visualizes reading habits, highlights streaks, and breaks down the overall health of the saved links inbox.

---

## ✦ Pull-to-Reveal Interaction

The Stats Dashboard is tucked away at the top of the Inbox to maintain a clean layout:
- **Reveal Gesture**: Pulling down on the Inbox header triggers a haptic pop and expands the metrics drawer.
- **Micro-Animations**: The container uses `AnimatedSize` and spring physics curve mappings to reveal metrics smoothly.
- **Swipe-up to Close**: Swiping up on the drawer collapses it back, returning focus to the primary reading list.

---

## ✦ Habit and Performance Metrics

The panel provides five key diagnostic tools to track your reading habits:

```
┌──────────────────────────────────────────────────────────┐
│                     Habit Diagnostics                    │
├──────────────────────────────────────────────────────────┤
│ 🔥 Reading Streak      | Daily consecutive read count.    │
│ 📊 Saved vs Read Chart | 7-day velocity check.            │
│ 📅 Contribution Grid   | 28-day GitHub-style calendar.   │
│ 🏷️ Inbox Health Band   | Decay category breakdown.       │
│ 🌐 Top Domain Sources  | Most bookmarked sites.           │
└──────────────────────────────────────────────────────────┘
```

### 1. Daily Reading Streak
Displays consecutive active days where you met your configured daily reading goal (e.g. reading 2 links per day). This helps encourage consistent, daily reading habits.

### 2. Saved vs. Read Velocity Chart
A 7-day sliding bar chart comparing saved link count against read link count. If the "Saved" bars consistently tower over the "Read" bars, the chart visually signals that you need to slow down bookmarks ingestion and focus on reading.

### 3. 28-Day Reading Heatmap Grid
A 4-week contribution calendar displaying a grid of daily reading history. Darker accent tiles highlight days with higher reading frequency, visualising your consistency over time.

### 4. Inbox Health Band
A stacked horizontal distribution bar displaying the percentage split of your inbox links: **Fresh**, **Fading**, **Stale**, and **Critical**. A healthy inbox should show mostly green and yellow bands, indicating low decay buildup.
