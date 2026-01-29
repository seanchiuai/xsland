# StarCy Creator Analytics — Dynamic Island

A minimal Dynamic Island implementation for displaying X (Twitter) creator analytics, designed around personalized baselines and event-driven triggers.

## Overview

StarCy surfaces just enough performance analytics in the Dynamic Island to help creators make better decisions without training them to ignore it. The Island only appears when something materially changes relative to the creator's personal baseline.

## Design Principles

- **Signal > coverage**: Only show metrics that change decisions
- **Personalized baselines**: "Good" is relative to the creator, not global averages
- **Event-driven**: Island appears only when performance deviates meaningfully
- **Trust-calibrated**: Always label time windows, never claim false attribution

## Metrics Selection

### Core Trio (always shown)

| Metric | Question it answers | Why |
|--------|-------------------|-----|
| **Engagement Rate** | "Was it good?" | Quality per reach — the north star for micro-influencers |
| **Impressions** | "Did it reach people?" | Reach foundation, always time-windowed |
| **Follower Delta** | "Is this growing my audience?" | Momentum signal, windowed and never attributed to a single tweet |

### Conditional Metric

| Metric | When shown |
|--------|-----------|
| **Link Clicks** | Only for link-driven creators (>20% tweets contain URLs) AND clicks exceed 2x creator's median |

### Not Shown

- **Profile visits**: Low actionability, mostly redundant with impressions
- **Raw likes/replies/retweets**: Too many numbers; ER + impressions subsume them
- **Revenue/monetization**: Not relevant for most micro-influencers

## Personalized Baselines

Every "show" decision is based on deviation from the creator's normal, not global averages:

- **Baseline ER**: Median engagement rate (last 30 tweets)
- **Baseline impressions**: Median impressions per tweet
- **Baseline velocity**: Median impressions/min in first 30 minutes
- **Baseline follower growth**: Avg followers/hour (last 7 days)

Uses median and robust stats to resist outliers.

## Trigger Logic (When the Island Appears)

The Island only shows when meaningful thresholds are crossed:

| Trigger | Condition |
|---------|-----------|
| **ER Spike** | ER >= 1.5x creator median AND impressions >= 200 |
| **Early Trending** | Velocity >= 2x median within 60min of posting |
| **Reach Milestone** | Impressions cross 2x, 5x, 10x baseline |
| **Follower Momentum** | Delta >= 1.5x avg AND >= +10 in 2h window |
| **Link Click Spike** | Clicks >= 2x median for link tweets AND >= 25 absolute |

### Anti-Annoyance Rules

- Max 3 Island appearances per day (attention budget)
- 3-hour cooldown between appearances (unless extreme anomaly)
- No appearance during Focus mode
- No repeat for same tweet if already viewed

## Island States

### Compact (Single Glance)
Context-aware — shows the metric that triggered the appearance:
- ER Spike: `🔥 6.2% ER`
- Trending: `📈 2.1×`
- Reach: `👀 18.4K`
- Followers: `+24 👤`
- Link clicks: `🔗 2.4×`

### Expanded (Long Press)
Max 3 lines of analytics:
- **Primary stat** with baseline comparison (e.g., "6.2% — 2.0× your typical")
- **Supporting stat** (impressions or ER, whichever isn't primary)
- **Tweet context** + follower delta + explainability line

Every expanded view includes a "why" sentence explaining the trigger.

### Minimal (Competing Activities)
Just the trigger-type icon.

## X API Integration

### Assumptions

| Requirement | Details |
|-------------|---------|
| **API Tier** | Basic ($100/mo) minimum |
| **Authentication** | OAuth 2.0 User Context |
| **Tweet Metrics** | `impression_count`, `like_count`, `reply_count`, `retweet_count`, `quote_count`, `bookmark_count`, `url_link_clicks`, `user_profile_clicks` |
| **Follower Count** | Snapshot via `GET /2/users/:id` |

### Polling Cadence

| Window | Interval |
|--------|----------|
| First 2 hours | Every 3-5 minutes |
| 2-24 hours | Every 15-30 minutes |
| 24-72 hours | Every 2-6 hours (or stop) |

### Attention Score (Content Selection)

When multiple tweets are performing, StarCy picks one using:

```
score(t) = 0.45 * d_er + 0.35 * d_velocity + 0.20 * d_impressions
```

Where each delta is the robust z-score vs creator baseline.

## Running the Demo

### Requirements
- Xcode 15+
- iOS 16.1+ deployment target
- iPhone 14 Pro or newer (for Dynamic Island)

### Steps
1. Open `StarCyCreatorAnalytics.xcodeproj`
2. Select a device/simulator
3. Build and run
4. Tap "Start Live Activity"
5. Tap "Simulate New Event" to cycle through trigger scenarios (ER spike, trending, reach milestone, follower momentum, link click spike)

### Note on Simulator
Dynamic Island does not render in Simulator. Lock Screen presentation works.

## Integration Guide

```swift
// Start (when trigger fires)
try LiveActivityManager.shared.start(
    handle: user.xHandle,
    initialState: computedEventState
)

// Update (when metrics refresh)
await LiveActivityManager.shared.update(with: newState)

// Stop (cooldown or user dismissal)
await LiveActivityManager.shared.stop()
```

## File Structure

```
StarCyCreatorAnalytics/
├── StarCyCreatorAnalytics/
│   ├── StarCyCreatorAnalyticsApp.swift
│   ├── ContentView.swift
│   ├── LiveActivityManager.swift
│   ├── MockAnalytics.swift
│   └── CreatorAnalyticsAttributes.swift  ← Shared (both targets)
│
├── CreatorAnalyticsWidget/
│   ├── CreatorAnalyticsWidgetBundle.swift
│   └── CreatorAnalyticsLiveActivity.swift
│
└── README.md
```

## License

MIT
