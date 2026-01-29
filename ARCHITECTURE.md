# Technical Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     StarCyCreatorAnalytics                      │
│                        (Main App Target)                        │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     ContentView                          │   │
│  │   • Demo controls (Start/Update/Stop buttons)           │   │
│  │   • Displays current mock state                         │   │
│  └────────────────────────┬────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 LiveActivityManager                      │   │
│  │   • start(handle:initialState:)                         │   │
│  │   • update(with:)                                       │   │
│  │   • stop()                                              │   │
│  │   • Manages Activity<CreatorAnalyticsAttributes>        │   │
│  └────────────────────────┬────────────────────────────────┘   │
│                           │                                     │
│                           │ ActivityKit                         │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              MockAnalytics (Data Generator)              │   │
│  │   • randomState() → ContentState                        │   │
│  │   • Simulates realistic micro-influencer metrics        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           CreatorAnalyticsAttributes (SHARED)            │   │
│  │   • ActivityAttributes protocol                         │   │
│  │   • ContentState with all metrics                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└───────────────────────────────────────────────────────────────┬─┘
                                                                │
                            ActivityKit Framework               │
                                                                │
┌───────────────────────────────────────────────────────────────┴─┐
│                   CreatorAnalyticsWidget                        │
│                   (Widget Extension Target)                     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           CreatorAnalyticsAttributes (SHARED)            │   │
│  │   • Same file, included in both targets                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │            CreatorAnalyticsLiveActivity                  │   │
│  │                                                          │   │
│  │   ActivityConfiguration(for: CreatorAnalyticsAttributes) │   │
│  │                           │                              │   │
│  │           ┌───────────────┼───────────────┐              │   │
│  │           ▼               ▼               ▼              │   │
│  │   ┌───────────┐   ┌───────────┐   ┌───────────────┐     │   │
│  │   │  Compact  │   │  Minimal  │   │   Expanded    │     │   │
│  │   │  Leading  │   │   View    │   │   Leading     │     │   │
│  │   │  Trailing │   │           │   │   Trailing    │     │   │
│  │   └───────────┘   └───────────┘   │   Center      │     │   │
│  │                                    │   Bottom      │     │   │
│  │                                    └───────────────┘     │   │
│  │                                                          │   │
│  │   ┌─────────────────────────────────────────────────┐   │   │
│  │   │              Lock Screen View                    │   │   │
│  │   └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           CreatorAnalyticsWidgetBundle                   │   │
│  │   @main entry point for extension                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## File → Target Mapping

| File | Main App | Widget Extension | Notes |
|------|:--------:|:----------------:|-------|
| `StarCyCreatorAnalyticsApp.swift` | ✅ | ❌ | App entry |
| `ContentView.swift` | ✅ | ❌ | Demo UI |
| `LiveActivityManager.swift` | ✅ | ❌ | Controls activity |
| `MockAnalytics.swift` | ✅ | ❌ | Fake data |
| `CreatorAnalyticsAttributes.swift` | ✅ | ✅ | **SHARED** |
| `CreatorAnalyticsLiveActivity.swift` | ❌ | ✅ | Island UI |
| `CreatorAnalyticsWidgetBundle.swift` | ❌ | ✅ | Extension entry |

---

## Data Flow

### Starting a Live Activity

```
User taps "Start"
        │
        ▼
ContentView calls LiveActivityManager.start()
        │
        ▼
LiveActivityManager creates ActivityContent with:
  - attributes: CreatorAnalyticsAttributes(handle: "demo_creator")
  - state: ContentState from MockAnalytics.randomState()
        │
        ▼
Activity.request(attributes:content:pushType:)
        │
        ▼
iOS renders Dynamic Island using CreatorAnalyticsLiveActivity
        │
        ├── Compact presentation (default)
        └── Expanded (on long press)
```

### Updating a Live Activity

```
User taps "Simulate Update"
        │
        ▼
ContentView calls LiveActivityManager.update()
        │
        ▼
LiveActivityManager creates new ActivityContent with:
  - state: new ContentState from MockAnalytics.randomState()
        │
        ▼
activity.update(content)
        │
        ▼
iOS animates transition in Dynamic Island
  - Numbers use .contentTransition(.numericText())
```

### Stopping a Live Activity

```
User taps "Stop"
        │
        ▼
ContentView calls LiveActivityManager.stop()
        │
        ▼
activity.end(nil, dismissalPolicy: .immediate)
        │
        ▼
Dynamic Island dismisses
```

---

## Dynamic Island Presentations

### Compact (Default State)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌─────────────┐              ┌───────────────────────┐   │
│   │   Leading   │   [CAMERA]   │       Trailing        │   │
│   │    📈       │              │       4.2% ↑          │   │
│   └─────────────┘              └───────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Leading: SF Symbol "chart.line.uptrend.xyaxis", cyan, 12pt
Trailing: "\(rate)%" + trend arrow, white, 14pt semibold
```

### Expanded (Long Press)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   LEADING                                       TRAILING    │
│   ┌────────────────────┐           ┌────────────────────┐  │
│   │ [Avatar] @handle   │           │      4.2% ↑        │  │
│   │ Creator Analytics  │           │    Engagement      │  │
│   └────────────────────┘           └────────────────────┘  │
│                                                             │
│   CENTER                                                    │
│   (empty - keeps layout clean)                             │
│                                                             │
│   BOTTOM                                                    │
│   ┌─────────────────────────────────────────────────────┐  │
│   │  👁 125.4K ↑       │      👤 +47                    │  │
│   │  Impressions       │      New Followers             │  │
│   │                                                     │  │
│   │  ┌─────────────────────────────────────────────┐   │  │
│   │  │ 🔥 Top Post                                  │   │  │
│   │  │ "Just shipped the new feature..."           │   │  │
│   │  │ ❤️ 892  🔁 134  💬 56                        │   │  │
│   │  └─────────────────────────────────────────────┘   │  │
│   └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Minimal (Competing Activities)

```
┌─────────┐
│   📈    │  Detached, circular/oval
└─────────┘
```

### Lock Screen

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  [📈]  @demo_creator                      4.2% ↑          │
│        StarCy Analytics              125.4K impressions    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### CreatorAnalyticsLiveActivity.swift Structure

```swift
struct CreatorAnalyticsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CreatorAnalyticsAttributes.self) { context in
            // Lock Screen presentation
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) { ... }
                DynamicIslandExpandedRegion(.trailing) { ... }
                DynamicIslandExpandedRegion(.center) { ... }
                DynamicIslandExpandedRegion(.bottom) { ... }
            } compactLeading: {
                // Compact left side
            } compactTrailing: {
                // Compact right side
            } minimal: {
                // Minimal presentation
            }
        }
    }
}

// MARK: - Compact Views
private struct CompactLeadingView: View { ... }
private struct CompactTrailingView: View { ... }

// MARK: - Minimal View
private struct MinimalView: View { ... }

// MARK: - Expanded Views
private struct ExpandedLeadingView: View { ... }
private struct ExpandedTrailingView: View { ... }
private struct ExpandedCenterView: View { ... }
private struct ExpandedBottomView: View { ... }

// MARK: - Lock Screen View
private struct LockScreenView: View { ... }

// MARK: - Reusable Components
private struct MetricCell: View { ... }
private struct TopPostRow: View { ... }
private struct PostStat: View { ... }

// MARK: - Helpers
private func formatEngagement(_ rate: Double) -> String { ... }
private func formatNumber(_ num: Int) -> String { ... }

// MARK: - Previews
#Preview("Compact", as: .dynamicIsland(.compact), ...) { ... }
#Preview("Expanded", as: .dynamicIsland(.expanded), ...) { ... }
#Preview("Minimal", as: .dynamicIsland(.minimal), ...) { ... }
#Preview("Lock Screen", as: .content, ...) { ... }
```

---

## Mock Data Ranges

Designed to feel realistic for micro-influencers:

| Metric | Range | Rationale |
|--------|-------|-----------|
| Engagement Rate | 2.5% – 6.0% | Micro-influencers typically see 2-4%, some higher |
| Impressions | 50K – 200K | Reasonable for 10K-50K follower accounts |
| New Followers (24h) | 10 – 100 | Daily fluctuation for active creators |
| Top Post Likes | 200 – 2000 | Typical engagement range |
| Top Post Reposts | 50 – 500 | Usually 1/4 to 1/3 of likes |
| Top Post Replies | 20 – 200 | Usually 1/10 to 1/5 of likes |

---

## Animation Notes

### Number Transitions
Use `.contentTransition(.numericText())` for smooth number changes:

```swift
Text(formatEngagement(context.state.engagementRate))
    .contentTransition(.numericText())
```

### Trend Arrows
Trend arrows should be static (no animation) — the color conveys meaning.

### Expanded Transition
The Dynamic Island handles expand/collapse animation automatically.

---

## Error Handling

### LiveActivityManager

```swift
func start(...) throws {
    // Check if Live Activities are enabled
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        throw LiveActivityError.notAuthorized
    }
    
    // End existing activity if any
    if let existing = currentActivity {
        Task { await existing.end(nil, dismissalPolicy: .immediate) }
    }
    
    // Request new activity
    let activity = try Activity.request(...)
    currentActivity = activity
}

enum LiveActivityError: LocalizedError {
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Live Activities are not enabled. Enable in Settings."
        }
    }
}
```

---

## Testing Notes

### Simulator Limitations
- Dynamic Island **does not render** in Simulator
- Lock Screen presentation **does work** in Simulator
- To test Dynamic Island: use physical iPhone 14 Pro or newer

### Preview Testing
- All previews should render in Xcode canvas
- Use previews as primary verification during development

### Manual Testing Checklist
1. Start activity → Lock Screen banner appears (Simulator)
2. Update activity → Values change
3. Stop activity → Banner dismisses
4. Start again → Works without issues
