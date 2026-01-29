# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**StarCy Creator Analytics** — a minimal iOS Dynamic Island demo app that displays X (Twitter) creator analytics for micro-influencers (1K–50K followers). Built with Swift, SwiftUI, WidgetKit, and ActivityKit. No external dependencies.

**Status**: Core UI and data model are implemented. The app is missing three entry-point/plumbing files needed to compile and run.

## What's Built

### Implemented

| File | Location | Lines | Description |
|------|----------|-------|-------------|
| `CreatorAnalyticsAttributes.swift` | Main App target (shared) | 66 | Data model — 5 metric types (engagementRate, trending, reachMilestone, followerMomentum, linkClicks), ContentState with engagement rate, impressions, follower delta, velocity, optional link clicks, explainability line |
| `CreatorAnalyticsLiveActivity.swift` | Widget Extension | 498 | Full Dynamic Island UI — compact, expanded, minimal, and lock screen presentations with previews, smart number formatting, numeric text transitions |
| `ContentView.swift` | Main App | 220 | Demo UI — event card display, Start/Simulate/Stop buttons, status indicator, error display |
| `MockAnalytics.swift` | Main App | 175 | 5 scenario generators (ER spike, trending, reach milestone, follower momentum, link clicks), mock tweet previews, realistic metric ranges |

### Not Implemented (3 Critical Missing Files)

| File | Location | Why It's Needed |
|------|----------|-----------------|
| `StarCyCreatorAnalyticsApp.swift` | Main App | `@main` entry point — app won't launch without it |
| `LiveActivityManager.swift` | Main App | Singleton that controls Activity lifecycle (start/update/stop) — ContentView depends on it |
| `CreatorAnalyticsWidgetBundle.swift` | Widget Extension | `@main` entry point for widget — extension won't load without it |

The project will not compile until all three files are added.

## Reference Documents

1. **CONTEXT.md** — Requirements, data model, UI specs, API assumptions
2. **PLAN.md** — 7-phase implementation sequence
3. **ARCHITECTURE.md** — System design, data flow, component breakdown
4. **CODE_TEMPLATES.md** — Reference Swift implementations for all files
5. **CLAUDE_CODE_INSTRUCTIONS.md** — Quick start guide, file checklist, success criteria

## Build & Run

This is an Xcode project (no CLI build).

- Open `StarCyCreatorAnalytics/StarCyCreatorAnalytics.xcodeproj` in Xcode
- Minimum deployment target: iOS 16.1
- Two targets: Main App (`com.starcy.creatoranalytics`) and Widget Extension (`com.starcy.creatoranalytics.widget`)
- Dynamic Island does NOT render in Simulator; Lock Screen presentation will
- Physical device testing requires iPhone 14 Pro or newer

## Architecture

### Two-Target Structure

```
StarCyCreatorAnalytics/              # Main App Target
  StarCyCreatorAnalyticsApp.swift      # @main entry point (MISSING)
  ContentView.swift                    # Demo UI with Start/Simulate/Stop
  LiveActivityManager.swift            # Activity lifecycle control (MISSING)
  MockAnalytics.swift                  # Fake metric generators
  CreatorAnalyticsAttributes.swift     # Shared data model (both targets)

CreatorAnalyticsWidget/              # Widget Extension Target
  CreatorAnalyticsWidgetBundle.swift    # @main for extension (MISSING)
  CreatorAnalyticsLiveActivity.swift   # All Dynamic Island UI views
```

### Data Flow

```
ContentView → LiveActivityManager.start/update/stop
  → Activity<CreatorAnalyticsAttributes>
    → CreatorAnalyticsLiveActivity (Widget Extension renders UI)
```

### Four Dynamic Island Presentations

1. **Compact** (default): Context-aware icon + primary metric
2. **Expanded** (long press): Full dashboard — primary stat, supporting metric, tweet context, follower delta, "why shown" explanation
3. **Minimal** (competing activities): Icon only
4. **Lock Screen**: Horizontal banner with all core metrics

## Critical Implementation Details

- `NSSupportsLiveActivities = YES` must be in the main app's Info.plist
- `CreatorAnalyticsAttributes.swift` must have membership in **both** targets
- ActivityKit model size budget: ~450 bytes (limit is 4KB)
- Activity stale date: 30 minutes
- Dismissal policy: `.immediate`
- Use `.contentTransition(.numericText())` for smooth metric update animations
- Primary accent color: Cyan (#00D4FF)

## Common Build Errors

- **"Cannot find type CreatorAnalyticsAttributes"** in widget target → File isn't in both target memberships (fix in Xcode)
- **Two `@main` entry points in widget target** → Delete Xcode-generated default widget files
- **Activity won't start** → Check `NSSupportsLiveActivities` in Info.plist and device Settings

## Scope Constraints

This is intentionally minimal. Do NOT add:
- Real X API integration (mock data only)
- OAuth flows, persistence, settings, onboarding
- External dependencies
