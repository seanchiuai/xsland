# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StarCy Creator Analytics — a minimal iOS Dynamic Island demo app that displays X (Twitter) creator analytics for micro-influencers (1K–50K followers). Built with Swift, SwiftUI, WidgetKit, and ActivityKit. No external dependencies.

**Status**: The project has detailed planning/architecture docs but no source code yet. Implementation should follow the phased plan in PLAN.md.

## Reference Documents (Read Order)

1. **CONTEXT.md** — Requirements, data model, UI specs, API assumptions
2. **PLAN.md** — 7-phase implementation sequence (follow exactly)
3. **ARCHITECTURE.md** — System design, data flow, component breakdown
4. **CODE_TEMPLATES.md** — Reference Swift implementations for all files

## Core Objective (Task)
Design a “Creator Analytics” Dynamic Island for StarCy focused on X (Twitter).

The idea: StarCy shows creators just enough analytics in the Dynamic Island without overwhelming them.

Show:
• What creator metrics appear in the Island (and why)
• Compact + expanded Island states
• How StarCy decides when to show analytics
• How it integrates with X’s API (assumptions are fine)

Keep it minimal 
Share via Figma or GitHub with a short README explaining your decisions.

## Build & Run

This is an Xcode project (no CLI build). Once the Xcode project exists:

- Open `StarCyCreatorAnalytics.xcodeproj` in Xcode
- Minimum deployment target: iOS 16.1
- Two targets: Main App (`com.starcy.creatoranalytics`) and Widget Extension (`com.starcy.creatoranalytics.widget`)
- Dynamic Island does NOT render in Simulator; Lock Screen presentation will
- Physical device testing requires iPhone 14 Pro or newer

## Implementation Phases — Human vs Claude

Several phases require manual Xcode GUI work that Claude Code cannot do. The user must step in at these points.

| Phase | What | Who |
|-------|------|-----|
| 1.1 | Create Xcode project (New iOS App, SwiftUI, iOS 16.1) | **Human (Xcode)** |
| 1.1 | Add Widget Extension target (File → New → Target, check "Include Live Activity") | **Human (Xcode)** |
| 1.2 | Add `NSSupportsLiveActivities = YES` to Info.plist | **Human (Xcode)** |
| 2 | Write `CreatorAnalyticsAttributes.swift` | Claude |
| 2 | Add `CreatorAnalyticsAttributes.swift` to both target memberships | **Human (Xcode)** |
| 3 | Write `CreatorAnalyticsLiveActivity.swift` | Claude |
| 4 | Write `CreatorAnalyticsWidgetBundle.swift`, delete Xcode-generated defaults | Claude + **Human (Xcode delete)** |
| 5 | Write `LiveActivityManager.swift`, `MockAnalytics.swift`, `ContentView.swift` | Claude |
| 6 | Set AccentColor to #00D4FF in Assets.xcassets | **Human (Xcode)** |
| 6 | Verify previews render, fix any build errors | **Human (Xcode)** |
| 7 | Write README.md | Claude |

## Architecture

### Two-Target Structure

```
StarCyCreatorAnalytics/          # Main App Target
  StarCyCreatorAnalyticsApp.swift  # @main entry point
  ContentView.swift                # Demo UI (Start/Update/Stop buttons)
  LiveActivityManager.swift        # Controls Live Activity lifecycle
  MockAnalytics.swift              # Generates fake metrics

CreatorAnalyticsWidget/           # Widget Extension Target
  CreatorAnalyticsWidgetBundle.swift  # @main for extension
  CreatorAnalyticsLiveActivity.swift  # All Dynamic Island UI views
```

### Shared Data Model

`CreatorAnalyticsAttributes.swift` must exist in **both targets** (main app + widget extension). This is the ActivityAttributes struct that bridges app control with widget presentation.

### Data Flow

```
ContentView → LiveActivityManager.start/update/stop
  → Activity<CreatorAnalyticsAttributes>
    → CreatorAnalyticsLiveActivity (Widget Extension renders UI)
```

### Four Dynamic Island Presentations

1. **Compact** (default): Engagement rate + trend arrow only
2. **Expanded** (long press): Full dashboard — engagement, impressions, followers, top post
3. **Minimal** (competing activities): Chart icon only
4. **Lock Screen**: Horizontal banner layout

## Critical Implementation Details

- `NSSupportsLiveActivities = YES` must be in the main app's Info.plist
- ActivityKit model size budget: ~450 bytes (limit is 4KB)
- Activity stale date: 30 minutes
- Dismissal policy: `.immediate`
- Use `.contentTransition(.numericText())` for smooth metric update animations
- Primary accent color: Cyan (#00D4FF)
- Preview syntax: `#Preview("Name", as: .dynamicIsland(.compact), using: attributes) { ... }`

## Coding Workflow

### Prerequisites (Human Must Do First)

Before Claude writes any code, the user must complete these Xcode GUI steps:

1. Create the Xcode project: New iOS App, SwiftUI, product name `StarCyCreatorAnalytics`, bundle ID `com.starcy.creatoranalytics`, iOS 16.1
2. Add Widget Extension target: File → New → Target → Widget Extension, product name `CreatorAnalyticsWidget`, check "Include Live Activity", uncheck "Include Configuration App Intent"
3. Add `NSSupportsLiveActivities = YES` to the main app's Info.plist

### File Creation Order

Write files in this exact sequence. Each file depends on the ones before it.

**Step 1 — Shared data model** (`CreatorAnalyticsAttributes.swift`):
- Location: Place in `StarCyCreatorAnalytics/` directory
- Imports: `ActivityKit`, `SwiftUI`, `Foundation`
- Contains: `CreatorAnalyticsAttributes` (conforms to `ActivityAttributes`), `TrendDirection` enum, `TopPostMetrics` struct
- The `ContentState` nested struct holds all dynamic fields: `engagementRate`, `engagementTrend`, `impressions`, `impressionsTrend`, `newFollowers`, `topPost`, `lastUpdated`
- **After creation**: User must add this file to both target memberships in Xcode (Main App + Widget Extension)

**Step 2 — Dynamic Island UI** (`CreatorAnalyticsLiveActivity.swift`):
- Location: `CreatorAnalyticsWidget/` directory, widget extension target only
- Imports: `SwiftUI`, `WidgetKit`, `ActivityKit`
- Main struct `CreatorAnalyticsLiveActivity: Widget` with `ActivityConfiguration`
- Build all four presentations: compact (leading + trailing), expanded (leading + trailing + bottom), minimal, lock screen
- Extract reusable sub-views: `MetricCell`, `TopPostRow`, `PostStat`
- Add helper functions: `formatEngagement(_:)`, `formatNumber(_:)`, `formatCompact(_:)`
- Include `#Preview` blocks for all four states (compact, expanded, minimal, lock screen / `.content`)
- Use `.contentTransition(.numericText())` on all numeric text fields
- All accent colors use `.cyan`

**Step 3 — Widget bundle** (`CreatorAnalyticsWidgetBundle.swift`):
- Location: `CreatorAnalyticsWidget/` directory
- This is the `@main` entry point for the widget extension
- Body contains only `CreatorAnalyticsLiveActivity()`
- **After creation**: User must delete Xcode-generated default widget files (e.g., `CreatorAnalyticsWidget.swift`, `CreatorAnalyticsWidgetBundle.swift` if auto-generated)

**Step 4 — Live Activity manager** (`LiveActivityManager.swift`):
- Location: `StarCyCreatorAnalytics/` directory, main app target only
- `@MainActor final class`, singleton via `static let shared`
- `@Published private(set) var currentActivity: Activity<CreatorAnalyticsAttributes>?`
- Three public methods: `start(handle:initialState:) throws`, `update(with:) async`, `stop() async`
- `start` checks `ActivityAuthorizationInfo().areActivitiesEnabled`, ends any existing activity, creates new one with 30-minute stale date and `pushType: nil`
- Include `observeActivity(_:)` to nil out `currentActivity` when dismissed
- Define `LiveActivityError` enum with `.notAuthorized` case

**Step 5 — Mock data** (`MockAnalytics.swift`):
- Location: `StarCyCreatorAnalytics/` directory, main app target only
- `static func randomState() -> CreatorAnalyticsAttributes.ContentState`
- Randomizes: engagement 2.5–6.0%, impressions 50K–200K, followers 10–100
- `static let mockPosts: [String]` with 5 sample post previews

**Step 6 — Demo UI** (`ContentView.swift`):
- Location: `StarCyCreatorAnalytics/` directory, main app target only
- `@StateObject private var activityManager = LiveActivityManager.shared`
- Three buttons: Start (`.borderedProminent`, `.tint(.cyan)`), Simulate Update (`.bordered`), Stop (`.bordered`, `.tint(.red)`)
- Status indicator with green/gray dot
- State card showing current mock data
- Local `formatNumber(_:)` for the card display

**Step 7 — App entry** (`StarCyCreatorAnalyticsApp.swift`):
- Should already exist from Xcode project creation
- Just wraps `ContentView()` in a `WindowGroup`

### Key Swift/ActivityKit Patterns

```swift
// Creating an activity
let content = ActivityContent(
    state: initialState,
    staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())
)
let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)

// Updating
await activity.update(ActivityContent(state: newState, staleDate: ...))

// Ending
await activity.end(nil, dismissalPolicy: .immediate)

// Preview syntax (WidgetKit)
#Preview("Name", as: .dynamicIsland(.compact), using: attributes) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    sampleContentState
}
```

### Common Build Errors and Fixes

- **"Cannot find type CreatorAnalyticsAttributes"** in widget target → File isn't in both target memberships (user must fix in Xcode)
- **"Cannot find 'Color' in scope"** → Missing `import SwiftUI` in `CreatorAnalyticsAttributes.swift` (needed for `TrendDirection.color`)
- **Two `@main` entry points in widget target** → Delete Xcode-generated default widget files
- **Activity won't start** → Check `NSSupportsLiveActivities` is in Info.plist and Live Activities are enabled in device Settings

### After All Code Is Written (Human Steps)

1. Set AccentColor to #00D4FF in Assets.xcassets
2. Delete any unused Xcode-generated template files in the widget target
3. Build and verify previews render in Xcode
4. Run on Simulator (Lock Screen presentation) or physical device (full Dynamic Island)

## Build Log

After completing any phase (or sub-step), append an entry to `docs/BUILD_LOG.md` with:
- Phase number and name
- Status: COMPLETE
- Date
- Done by: Human or Claude
- Actions: bullet list of what was done

Always read `docs/BUILD_LOG.md` and `docs/CURRENT_PHASE.md` before starting work to know what's already been completed and what phase is active. Never overwrite existing entries in `BUILD_LOG.md` — only append. Update `CURRENT_PHASE.md` to reflect the new active phase after completing one.

## Scope Constraints

This is intentionally minimal. Do NOT add:
- Real X API integration (mock data only)
- OAuth flows, persistence, settings, onboarding, or tests
- External dependencies
