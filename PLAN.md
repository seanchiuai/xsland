# Implementation Plan

## Build Order

Execute in this exact sequence:

---

## Phase 1: Project Setup

### Step 1.1: Create Xcode Project
```
1. New iOS App project
   - Product Name: StarCyCreatorAnalytics
   - Bundle ID: com.starcy.creatoranalytics
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 16.1

2. Add Widget Extension target
   - File → New → Target → Widget Extension
   - Product Name: CreatorAnalyticsWidget
   - Check "Include Live Activity"
   - Uncheck "Include Configuration App Intent" (not needed)
```

### Step 1.2: Configure Info.plist
```xml
<!-- Main App Info.plist -->
<key>NSSupportsLiveActivities</key>
<true/>
```

---

## Phase 2: Shared Data Model

### Step 2.1: Create CreatorAnalyticsAttributes.swift

**Location**: Must be in BOTH targets (Main App + Widget Extension)

```swift
// CreatorAnalyticsAttributes.swift

import ActivityKit
import Foundation

struct CreatorAnalyticsAttributes: ActivityAttributes {
    let handle: String
    
    struct ContentState: Codable, Hashable {
        let engagementRate: Double
        let engagementTrend: TrendDirection
        let impressions: Int
        let impressionsTrend: TrendDirection
        let newFollowers: Int
        let topPost: TopPostMetrics?
        let lastUpdated: Date
    }
}

enum TrendDirection: String, Codable, Hashable {
    case up, down, stable
    
    var symbol: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
}

struct TopPostMetrics: Codable, Hashable {
    let preview: String
    let likes: Int
    let reposts: Int
    let replies: Int
}
```

**Important**: Add this file to BOTH target memberships in Xcode.

---

## Phase 3: Widget Extension (Dynamic Island UI)

### Step 3.1: Create CreatorAnalyticsLiveActivity.swift

**Location**: CreatorAnalyticsWidget target only

Build these components:

1. **Main Widget struct** with `ActivityConfiguration`
2. **Compact Leading** — Brand icon (📈)
3. **Compact Trailing** — Engagement rate + trend
4. **Minimal** — Just the icon
5. **Expanded Regions**:
   - Leading: Profile + handle
   - Trailing: Primary metric (engagement)
   - Bottom: Impressions, followers, top post
6. **Lock Screen** — Horizontal layout

### Step 3.2: Helper Views

Create reusable components:
- `MetricCell` — Icon + value + label + optional trend
- `TrendArrow` — Animated arrow with color
- `TopPostRow` — Post preview with stats
- `PostStat` — Small stat display (❤️ 892)

### Step 3.3: Helper Functions

```swift
func formatEngagement(_ rate: Double) -> String {
    String(format: "%.1f%%", rate)
}

func formatNumber(_ num: Int) -> String {
    if num >= 1_000_000 {
        return String(format: "%.1fM", Double(num) / 1_000_000)
    } else if num >= 1_000 {
        return String(format: "%.1fK", Double(num) / 1_000)
    }
    return "\(num)"
}
```

### Step 3.4: Preview Providers

Add SwiftUI previews for all states:
- `.dynamicIsland(.compact)`
- `.dynamicIsland(.expanded)`
- `.dynamicIsland(.minimal)`
- `.content` (Lock Screen)

---

## Phase 4: Widget Bundle

### Step 4.1: Create CreatorAnalyticsWidgetBundle.swift

**Location**: CreatorAnalyticsWidget target

```swift
import SwiftUI
import WidgetKit

@main
struct CreatorAnalyticsWidgetBundle: WidgetBundle {
    var body: some Widget {
        CreatorAnalyticsLiveActivity()
    }
}
```

**Note**: Delete the default Widget.swift file that Xcode generates.

---

## Phase 5: Main App

### Step 5.1: Create LiveActivityManager.swift

**Location**: Main App target only

```swift
@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    @Published private(set) var currentActivity: Activity<CreatorAnalyticsAttributes>?
    
    var isActive: Bool { currentActivity != nil }
    
    func start(handle: String, initialState: CreatorAnalyticsAttributes.ContentState) throws { ... }
    func update(with state: CreatorAnalyticsAttributes.ContentState) async { ... }
    func stop() async { ... }
}
```

### Step 5.2: Create MockAnalytics.swift

**Location**: Main App target only

```swift
struct MockAnalytics {
    static func randomState() -> CreatorAnalyticsAttributes.ContentState { ... }
    static let mockPosts: [String] = [ ... ]
}
```

### Step 5.3: Create ContentView.swift

**Location**: Main App target

Simple demo UI with:
- Current state display (card showing mock data)
- "Start Live Activity" button
- "Simulate Update" button
- "Stop" button
- Status indicator

### Step 5.4: Update App Entry Point

```swift
@main
struct StarCyCreatorAnalyticsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## Phase 6: Polish

### Step 6.1: Assets

Add to Assets.xcassets:
- AccentColor (cyan: #00D4FF)
- Optional: App icon

### Step 6.2: Clean Up

- Delete any unused template files
- Ensure no compiler warnings
- Test previews render correctly

---

## Phase 7: Documentation

### Step 7.1: Create README.md

Cover all required sections:
1. Overview
2. Metrics Selection (with rationale)
3. Design Decisions
4. When to Show Analytics
5. X API Integration Assumptions
6. Running the Demo
7. Integration Guide

---

## Verification Checklist

Before considering complete:

- [ ] Project builds without errors
- [ ] All 4 Dynamic Island previews render in Xcode
- [ ] Demo app launches in Simulator
- [ ] "Start" button triggers Live Activity (Lock Screen visible in Simulator)
- [ ] "Update" button changes displayed values
- [ ] "Stop" button ends activity
- [ ] README explains all decisions
- [ ] Code is clean and minimal

---

## Common Pitfalls to Avoid

1. **Target Membership**: `CreatorAnalyticsAttributes.swift` MUST be in both targets
2. **Widget Bundle**: Don't forget `@main` on the WidgetBundle
3. **Info.plist**: Must have `NSSupportsLiveActivities = YES`
4. **Simulator**: Dynamic Island doesn't render in Simulator, but Lock Screen does
5. **Preview Data**: Always provide valid sample data for previews
