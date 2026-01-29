# StarCy Creator Analytics — Dynamic Island

## Project Overview

Build a **minimal, working iOS Dynamic Island** that displays X (Twitter) creator analytics. This is a feature demo for StarCy (a mysterious company). The deliverable is a GitHub repo with working SwiftUI code and a README explaining design decisions.

---

## Original Requirements

```
Design a "Creator Analytics" Dynamic Island for StarCy, focused on X (Twitter).
The idea: StarCy shows creators just enough analytics in the Dynamic Island without overwhelming them.
Show:
• What creator metrics appear in the Island (and why)
• Compact + expanded Island states
• How StarCy decides when to show analytics
• How it integrates with X's API (assumptions are fine)
Keep it minimal
Share via Figma or GitHub with a short README explaining your decisions.
```

---

## What to Build

### Deliverables
1. **Working SwiftUI Widget Extension** — Dynamic Island UI only
2. **Minimal Demo App** — Just enough to trigger the Live Activity
3. **README.md** — Explains metrics, decisions, API assumptions

### NOT Building
- Full app architecture
- Real X API integration
- OAuth flows
- Settings/onboarding screens
- Database/persistence
- Tests

---

## Target User

**Micro-influencers (1K–50K followers)** who want glanceable analytics without opening an app.

---

## File Structure

```
StarCyCreatorAnalytics/
├── StarCyCreatorAnalytics/                    # Main App (minimal)
│   ├── StarCyCreatorAnalyticsApp.swift        # @main entry
│   ├── ContentView.swift                       # Demo controls
│   ├── LiveActivityManager.swift               # start/update/stop API
│   └── Assets.xcassets/
│
├── CreatorAnalyticsWidget/                     # Widget Extension
│   ├── CreatorAnalyticsAttributes.swift        # Data model
│   ├── CreatorAnalyticsLiveActivity.swift      # All Dynamic Island UI
│   ├── CreatorAnalyticsWidgetBundle.swift      # @main for extension
│   └── Assets.xcassets/
│
└── README.md
```

---

## Technical Requirements

### iOS Version
- Minimum: iOS 16.1 (Dynamic Island support)
- Target devices: iPhone 14 Pro and newer

### Frameworks
- SwiftUI
- WidgetKit
- ActivityKit

### No External Dependencies
Everything uses Apple's native frameworks.

---

## Data Model

### CreatorAnalyticsAttributes (ActivityAttributes)

```swift
struct CreatorAnalyticsAttributes: ActivityAttributes {
    // Static (set once)
    let handle: String                    // X handle without @
    
    // Dynamic (updates)
    struct ContentState: Codable, Hashable {
        let engagementRate: Double        // e.g., 4.2 (meaning 4.2%)
        let engagementTrend: TrendDirection
        let impressions: Int              // e.g., 125400
        let impressionsTrend: TrendDirection
        let newFollowers: Int             // e.g., 47
        let topPost: TopPostMetrics?      // Optional
        let lastUpdated: Date
    }
}

enum TrendDirection: String, Codable, Hashable {
    case up, down, stable
}

struct TopPostMetrics: Codable, Hashable {
    let preview: String                   // First ~30 chars
    let likes: Int
    let reposts: Int
    let replies: Int
}
```

### Size Budget
- ActivityKit limit: 4KB
- Our model: ~450 bytes (well under)

---

## UI Specifications

### Metrics Hierarchy

| Priority | Metric | Compact | Expanded | Why |
|----------|--------|---------|----------|-----|
| 1 | Engagement Rate | ✅ | ✅ | North star for micro-influencers |
| 2 | Trend Arrow | ✅ | ✅ | Instant context |
| 3 | Impressions | — | ✅ | Reach foundation |
| 4 | New Followers | — | ✅ | Growth signal |
| 5 | Top Post | — | ✅ | Actionable insight |

### Compact Presentation
```
┌────────────────────────────────────────────────────┐
│ [📈]                              [4.2% ↑]        │
│  ^                                   ^            │
│  Leading                        Trailing          │
│  (brand icon)                   (rate + trend)    │
└────────────────────────────────────────────────────┘
```
- Leading: SF Symbol `chart.line.uptrend.xyaxis` in cyan
- Trailing: Engagement rate + trend arrow

### Expanded Presentation
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  [👤]  @handle                          4.2% ↑             │
│        Creator Analytics               Engagement           │
│                                                             │
│  ───────────────────────────────────────────────────────── │
│                                                             │
│   👁 125.4K ↑              👤 +47                           │
│   Impressions              New Followers                    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔥 Top Post                                          │   │
│  │ "Just shipped the new feature..."                    │   │
│  │ ❤️ 892  🔁 134  💬 56                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Minimal Presentation (when competing with other activities)
```
┌──────┐
│  📈  │
└──────┘
```

### Lock Screen Presentation
Horizontal layout with handle on left, key metrics on right.

### Colors
| Element | Color | Hex |
|---------|-------|-----|
| Primary Accent | Cyan | #00D4FF |
| Trend Up | Green | #34C759 (system green) |
| Trend Down | Red | #FF3B30 (system red) |
| Trend Stable | Gray | #8E8E93 |
| Text Primary | White | #FFFFFF |
| Text Secondary | Gray | #8E8E93 |

### Typography
- Primary metric: SF Pro Rounded, 20pt, Bold
- Compact metric: SF Pro Rounded, 14pt, Semibold
- Labels: SF Pro, 10pt, Regular
- Handle: SF Pro, 13pt, Semibold

---

## LiveActivityManager API

```swift
@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    @Published private(set) var isActive: Bool = false
    
    /// Start the Dynamic Island with initial data
    func start(handle: String, initialState: CreatorAnalyticsAttributes.ContentState) throws
    
    /// Update with new analytics data
    func update(with state: CreatorAnalyticsAttributes.ContentState) async
    
    /// End the Live Activity
    func stop() async
}
```

---

## Demo App Behavior

Simple single-screen app:

```
┌─────────────────────────────────────┐
│                                     │
│       StarCy Analytics Demo         │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  @demo_creator              │   │
│   │  Engagement: 4.2% ↑         │   │
│   │  Impressions: 125.4K        │   │
│   │  New Followers: +47         │   │
│   └─────────────────────────────┘   │
│                                     │
│      [ Start Live Activity ]        │
│                                     │
│      [ Simulate Update ]            │
│                                     │
│      [ Stop ]                       │
│                                     │
│                                     │
│   Status: Not Active                │
│                                     │
└─────────────────────────────────────┘
```

- **Start**: Triggers Dynamic Island with mock data
- **Simulate Update**: Generates new random metrics, updates Island
- **Stop**: Ends the Live Activity

---

## Mock Data Generation

```swift
struct MockAnalytics {
    static func randomState() -> CreatorAnalyticsAttributes.ContentState {
        let engagement = Double.random(in: 2.5...6.0)
        let previousEngagement = Double.random(in: 2.5...6.0)
        
        return .init(
            engagementRate: engagement,
            engagementTrend: engagement > previousEngagement ? .up : (engagement < previousEngagement ? .down : .stable),
            impressions: Int.random(in: 50_000...200_000),
            impressionsTrend: [.up, .down, .stable].randomElement()!,
            newFollowers: Int.random(in: 10...100),
            topPost: TopPostMetrics(
                preview: mockPosts.randomElement()!,
                likes: Int.random(in: 200...2000),
                reposts: Int.random(in: 50...500),
                replies: Int.random(in: 20...200)
            ),
            lastUpdated: Date()
        )
    }
    
    static let mockPosts = [
        "Just shipped the new feature...",
        "Thread: What I learned building...",
        "Hot take: AI won't replace...",
        "Unpopular opinion about startups...",
        "3 things nobody tells you about..."
    ]
}
```

---

## Xcode Project Setup

### Targets
1. **StarCyCreatorAnalytics** (iOS App)
   - Bundle ID: `com.starcy.creatoranalytics`
   - Deployment: iOS 16.1+

2. **CreatorAnalyticsWidgetExtension** (Widget Extension)
   - Bundle ID: `com.starcy.creatoranalytics.widget`
   - Deployment: iOS 16.1+

### Info.plist (Main App)
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### Capabilities
- Main App: None required (Live Activities enabled via Info.plist)
- Widget Extension: Automatically configured

---

## SwiftUI Preview Requirements

Include preview providers for all Dynamic Island states:

```swift
#Preview("Compact", as: .dynamicIsland(.compact), using: previewAttributes) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    previewState
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: previewAttributes) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    previewState
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: previewAttributes) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    previewState
}

#Preview("Lock Screen", as: .content, using: previewAttributes) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    previewState
}
```

---

## README Structure

The README.md should cover:

### 1. Overview
What this is and who it's for.

### 2. Metrics Selection
Why engagement rate is primary, why we show what we show.

### 3. Design Decisions
- Compact: Only engagement (most important, glanceable)
- Expanded: Full picture without overwhelming
- Visual hierarchy and information density

### 4. When to Show Analytics
- User explicitly enables it
- Runs while creator wants passive feedback
- Auto-ends after 8 hours or manual stop

### 5. X API Integration (Assumptions)
- Requires Basic tier ($100/mo) minimum
- Uses OAuth 2.0 User Context for private metrics
- Polls every 15 minutes (respects rate limits)
- Endpoints: `/2/users/:id/tweets` with `tweet.fields=public_metrics,non_public_metrics`

### 6. Running the Demo
How to build and test in Xcode.

### 7. Integration Guide
How StarCy would integrate this into their app.

---

## Success Criteria

1. **Works**: Dynamic Island appears and updates
2. **Looks good**: Clean, minimal, Apple-native feel
3. **Makes sense**: README clearly explains decisions
4. **Minimal**: No unnecessary code or complexity
