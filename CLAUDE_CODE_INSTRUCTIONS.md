# CLAUDE_CODE_INSTRUCTIONS.md

## Quick Start

You are building a **minimal iOS Dynamic Island** demo for StarCy, a creator analytics app focused on X (Twitter).

---

## Read These Files First

1. **CONTEXT.md** — Full project overview, requirements, specs
2. **PLAN.md** — Step-by-step implementation order
3. **ARCHITECTURE.md** — System design, data flow, component breakdown
4. **CODE_TEMPLATES.md** — Ready-to-use Swift code

---

## What You're Building

```
┌─────────────────────────────────────────────────┐
│                                                 │
│   A working iOS app with:                       │
│                                                 │
│   1. Dynamic Island UI (SwiftUI + ActivityKit) │
│      - Compact: engagement rate + trend        │
│      - Expanded: full metrics dashboard        │
│      - Lock Screen: horizontal banner          │
│                                                 │
│   2. Demo app to trigger it                    │
│      - Start/Update/Stop buttons               │
│      - Mock data generator                     │
│                                                 │
│   3. README explaining decisions               │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Critical Requirements

### Must Have
- [x] Widget Extension with Live Activity
- [x] All Dynamic Island presentations (compact, expanded, minimal)
- [x] Lock Screen presentation
- [x] LiveActivityManager with start/update/stop
- [x] Mock data that simulates realistic metrics
- [x] Xcode previews for all states
- [x] README with design rationale

### Must NOT Have
- [ ] Real X API integration (use mock data)
- [ ] OAuth flows
- [ ] Persistence/database
- [ ] Settings screens
- [ ] Onboarding
- [ ] Tests
- [ ] Over-engineering

---

## File Checklist

Create these files exactly:

### Main App Target
- [ ] `StarCyCreatorAnalyticsApp.swift` — App entry point
- [ ] `ContentView.swift` — Demo UI with buttons
- [ ] `LiveActivityManager.swift` — Controls the Live Activity
- [ ] `MockAnalytics.swift` — Generates fake data
- [ ] `CreatorAnalyticsAttributes.swift` — **SHARED** (add to both targets)

### Widget Extension Target
- [ ] `CreatorAnalyticsWidgetBundle.swift` — Extension entry point
- [ ] `CreatorAnalyticsLiveActivity.swift` — All Dynamic Island UI
- [ ] `CreatorAnalyticsAttributes.swift` — **SHARED** (same file, both targets)

### Root
- [ ] `README.md` — Documentation

---

## Key Technical Notes

1. **Target Membership**: `CreatorAnalyticsAttributes.swift` MUST be in BOTH targets
2. **Info.plist**: Add `NSSupportsLiveActivities = YES` to main app
3. **Previews**: Use `#Preview("Name", as: .dynamicIsland(.compact), ...)` syntax
4. **Simulator**: Dynamic Island won't render — Lock Screen will
5. **iOS Version**: Minimum 16.1

---

## Success Criteria

✅ Project builds without errors
✅ All 4 Dynamic Island previews render in Xcode
✅ Demo app launches
✅ Start button triggers Live Activity
✅ Update button changes values
✅ Stop button ends activity
✅ README is complete and clear
✅ Code is minimal and clean

---

## Go Build It

Start with PLAN.md Phase 1 and work through sequentially.
Use CODE_TEMPLATES.md as your reference implementation.
