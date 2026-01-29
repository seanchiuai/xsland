# Code Templates

Reference implementations for each file. Adapt as needed.

---

## CreatorAnalyticsAttributes.swift (SHARED - Both Targets)

```swift
import ActivityKit
import SwiftUI
import Foundation

// MARK: - Activity Attributes

struct CreatorAnalyticsAttributes: ActivityAttributes {
    /// Creator's X handle (without @)
    let handle: String
    
    /// Dynamic content that updates during the activity
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

// MARK: - Supporting Types

enum TrendDirection: String, Codable, Hashable {
    case up
    case down
    case stable
    
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
    
    static func random() -> TrendDirection {
        [.up, .down, .stable].randomElement()!
    }
}

struct TopPostMetrics: Codable, Hashable {
    let preview: String
    let likes: Int
    let reposts: Int
    let replies: Int
}
```

---

## CreatorAnalyticsLiveActivity.swift (Widget Extension Only)

```swift
import SwiftUI
import WidgetKit
import ActivityKit

struct CreatorAnalyticsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CreatorAnalyticsAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                CompactLeadingView()
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView()
            }
        }
    }
}

// MARK: - Compact Views

private struct CompactLeadingView: View {
    var body: some View {
        Image(systemName: "chart.line.uptrend.xyaxis")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.cyan)
    }
}

private struct CompactTrailingView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    
    var body: some View {
        HStack(spacing: 2) {
            Text(formatEngagement(context.state.engagementRate))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            
            Image(systemName: context.state.engagementTrend.symbol)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(context.state.engagementTrend.color)
        }
    }
}

// MARK: - Minimal View

private struct MinimalView: View {
    var body: some View {
        Image(systemName: "chart.line.uptrend.xyaxis")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.cyan)
    }
}

// MARK: - Expanded Views

private struct ExpandedLeadingView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.cyan.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.cyan)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(context.attributes.handle)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text("Creator Analytics")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ExpandedTrailingView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
                Text(formatEngagement(context.state.engagementRate))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                Image(systemName: context.state.engagementTrend.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(context.state.engagementTrend.color)
            }
            
            Text("Engagement")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

private struct ExpandedBottomView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                MetricCell(
                    icon: "eye.fill",
                    value: formatNumber(context.state.impressions),
                    label: "Impressions",
                    trend: context.state.impressionsTrend
                )
                
                Divider()
                    .frame(height: 30)
                    .background(.white.opacity(0.1))
                
                MetricCell(
                    icon: "person.badge.plus.fill",
                    value: "+\(context.state.newFollowers)",
                    label: "New Followers",
                    trend: nil
                )
            }
            
            if let topPost = context.state.topPost {
                TopPostRow(topPost: topPost)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Lock Screen View

private struct LockScreenView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(.cyan.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 18))
                            .foregroundStyle(.cyan)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("@\(context.attributes.handle)")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("StarCy Analytics")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text(formatEngagement(context.state.engagementRate))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Image(systemName: context.state.engagementTrend.symbol)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(context.state.engagementTrend.color)
                }
                
                Text("\(formatNumber(context.state.impressions)) impressions")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .activityBackgroundTint(.black.opacity(0.8))
    }
}

// MARK: - Reusable Components

private struct MetricCell: View {
    let icon: String
    let value: String
    let label: String
    let trend: TrendDirection?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.cyan.opacity(0.8))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    
                    if let trend = trend {
                        Image(systemName: trend.symbol)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(trend.color)
                    }
                }
                
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TopPostRow: View {
    let topPost: TopPostMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                
                Text("Top Post")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Text(topPost.preview)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
            
            HStack(spacing: 12) {
                PostStat(icon: "heart.fill", value: topPost.likes)
                PostStat(icon: "arrow.2.squarepath", value: topPost.reposts)
                PostStat(icon: "bubble.left.fill", value: topPost.replies)
            }
        }
        .padding(10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct PostStat: View {
    let icon: String
    let value: Int
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            
            Text(formatCompact(value))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Helpers

private func formatEngagement(_ rate: Double) -> String {
    String(format: "%.1f%%", rate)
}

private func formatNumber(_ num: Int) -> String {
    if num >= 1_000_000 {
        return String(format: "%.1fM", Double(num) / 1_000_000)
    } else if num >= 1_000 {
        return String(format: "%.1fK", Double(num) / 1_000)
    }
    return "\(num)"
}

private func formatCompact(_ num: Int) -> String {
    if num >= 1_000 {
        return String(format: "%.0fK", Double(num) / 1_000)
    }
    return "\(num)"
}

// MARK: - Previews

#Preview("Compact", as: .dynamicIsland(.compact), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    CreatorAnalyticsAttributes.ContentState(
        engagementRate: 4.2,
        engagementTrend: .up,
        impressions: 125400,
        impressionsTrend: .up,
        newFollowers: 47,
        topPost: TopPostMetrics(preview: "Just shipped the new feature...", likes: 892, reposts: 134, replies: 56),
        lastUpdated: Date()
    )
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    CreatorAnalyticsAttributes.ContentState(
        engagementRate: 4.2,
        engagementTrend: .up,
        impressions: 125400,
        impressionsTrend: .up,
        newFollowers: 47,
        topPost: TopPostMetrics(preview: "Just shipped the new feature...", likes: 892, reposts: 134, replies: 56),
        lastUpdated: Date()
    )
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    CreatorAnalyticsAttributes.ContentState(
        engagementRate: 4.2,
        engagementTrend: .up,
        impressions: 125400,
        impressionsTrend: .up,
        newFollowers: 47,
        topPost: nil,
        lastUpdated: Date()
    )
}

#Preview("Lock Screen", as: .content, using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    CreatorAnalyticsAttributes.ContentState(
        engagementRate: 4.2,
        engagementTrend: .up,
        impressions: 125400,
        impressionsTrend: .up,
        newFollowers: 47,
        topPost: nil,
        lastUpdated: Date()
    )
}
```

---

## CreatorAnalyticsWidgetBundle.swift (Widget Extension Only)

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

---

## LiveActivityManager.swift (Main App Only)

```swift
import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    
    static let shared = LiveActivityManager()
    
    @Published private(set) var currentActivity: Activity<CreatorAnalyticsAttributes>?
    
    var isActive: Bool {
        currentActivity != nil
    }
    
    private init() {}
    
    func start(handle: String, initialState: CreatorAnalyticsAttributes.ContentState) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notAuthorized
        }
        
        // End existing activity
        if let existing = currentActivity {
            Task {
                await existing.end(nil, dismissalPolicy: .immediate)
            }
        }
        
        let attributes = CreatorAnalyticsAttributes(handle: handle)
        let content = ActivityContent(
            state: initialState,
            staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())
        )
        
        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
        
        currentActivity = activity
        observeActivity(activity)
    }
    
    func update(with state: CreatorAnalyticsAttributes.ContentState) async {
        guard let activity = currentActivity else { return }
        
        let content = ActivityContent(
            state: state,
            staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())
        )
        
        await activity.update(content)
    }
    
    func stop() async {
        guard let activity = currentActivity else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
    }
    
    private func observeActivity(_ activity: Activity<CreatorAnalyticsAttributes>) {
        Task {
            for await state in activity.activityStateUpdates {
                if state == .dismissed {
                    await MainActor.run {
                        if self.currentActivity?.id == activity.id {
                            self.currentActivity = nil
                        }
                    }
                }
            }
        }
    }
}

enum LiveActivityError: LocalizedError {
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Live Activities are not enabled. Please enable in Settings."
        }
    }
}
```

---

## MockAnalytics.swift (Main App Only)

```swift
import Foundation

struct MockAnalytics {
    
    static func randomState() -> CreatorAnalyticsAttributes.ContentState {
        let engagement = Double.random(in: 2.5...6.0)
        
        return CreatorAnalyticsAttributes.ContentState(
            engagementRate: (engagement * 10).rounded() / 10, // Round to 1 decimal
            engagementTrend: .random(),
            impressions: Int.random(in: 50_000...200_000),
            impressionsTrend: .random(),
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

## ContentView.swift (Main App Only)

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var activityManager = LiveActivityManager.shared
    @State private var currentState = MockAnalytics.randomState()
    @State private var errorMessage: String?
    
    private let handle = "demo_creator"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Current State Card
                stateCard
                
                // Controls
                VStack(spacing: 12) {
                    Button(action: startActivity) {
                        Label("Start Live Activity", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                    .disabled(activityManager.isActive)
                    
                    Button(action: updateActivity) {
                        Label("Simulate Update", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!activityManager.isActive)
                    
                    Button(action: stopActivity) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(!activityManager.isActive)
                }
                
                // Status
                HStack {
                    Circle()
                        .fill(activityManager.isActive ? .green : .gray)
                        .frame(width: 8, height: 8)
                    Text(activityManager.isActive ? "Live Activity Active" : "Not Active")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("StarCy Demo")
        }
    }
    
    private var stateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("@\(handle)")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Text(String(format: "%.1f%%", currentState.engagementRate))
                        .font(.title2.bold())
                    Image(systemName: currentState.engagementTrend.symbol)
                        .foregroundStyle(currentState.engagementTrend.color)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Impressions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatNumber(currentState.impressions))
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("New Followers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("+\(currentState.newFollowers)")
                        .font(.subheadline.bold())
                }
            }
            
            if let topPost = currentState.topPost {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Post")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(topPost.preview)
                        .font(.subheadline)
                        .lineLimit(1)
                    HStack(spacing: 16) {
                        Label("\(topPost.likes)", systemImage: "heart.fill")
                        Label("\(topPost.reposts)", systemImage: "arrow.2.squarepath")
                        Label("\(topPost.replies)", systemImage: "bubble.left.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func startActivity() {
        errorMessage = nil
        do {
            try activityManager.start(handle: handle, initialState: currentState)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func updateActivity() {
        currentState = MockAnalytics.randomState()
        Task {
            await activityManager.update(with: currentState)
        }
    }
    
    private func stopActivity() {
        Task {
            await activityManager.stop()
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", Double(num) / 1_000)
        }
        return "\(num)"
    }
}

#Preview {
    ContentView()
}
```

---

## StarCyCreatorAnalyticsApp.swift (Main App Only)

```swift
import SwiftUI

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

## README.md

```markdown
# StarCy Creator Analytics — Dynamic Island

A minimal Dynamic Island implementation for displaying X (Twitter) creator analytics.

## Overview

This demo shows how StarCy could display glanceable analytics for micro-influencers (1K–50K followers) directly in the Dynamic Island, without requiring them to open an app.

## Metrics Selection

### Why These Metrics?

| Metric | Priority | Rationale |
|--------|----------|-----------|
| **Engagement Rate** | Primary | The north star for micro-influencers. More meaningful than follower count. Industry benchmark: 2-4% is good, 3%+ is excellent on X. |
| **Trend Arrow** | Primary | Instant context on whether things are improving or declining. |
| **Impressions** | Secondary | Shows reach — the foundation for engagement. |
| **New Followers** | Secondary | Growth signal and immediate feedback on content performance. |
| **Top Post** | Tertiary | Actionable insight — shows what's working. |

### What We Didn't Include

- **Follower count**: Vanity metric, less useful than engagement rate
- **Detailed post-by-post breakdown**: Too much for a glance
- **Revenue/monetization**: Not relevant for most micro-influencers

## Design Decisions

### Compact View (Default)
Shows only **engagement rate + trend**. This is the single most important metric, and it fits in a glance.

### Expanded View (Long Press)
Reveals the full picture: engagement, impressions, new followers, and top post preview. Organized in clear hierarchy without overwhelming.

### Visual Language
- **Cyan accent**: Distinctive, not confused with X's blue
- **SF Pro Rounded**: For metrics (friendly, modern)
- **Minimal chrome**: Let the data speak

## When to Show Analytics

StarCy would show the Dynamic Island when:

1. **User explicitly enables it** — Via toggle in the app
2. **Creator wants passive feedback** — While working on other things
3. **Auto-ends after 8 hours** — Or manual stop

The Island is **not** for:
- Constant monitoring (that's what the full app is for)
- Alerts/notifications (too disruptive)
- Advertising

## X API Integration

### Assumptions

| Requirement | Details |
|-------------|---------|
| **API Tier** | Basic ($100/mo) minimum — Free tier cannot read data |
| **Authentication** | OAuth 2.0 User Context (user authorizes StarCy) |
| **Endpoints** | `GET /2/users/:id/tweets` with `tweet.fields=public_metrics,non_public_metrics` |
| **Refresh Rate** | Every 15 minutes (respects rate limits) |
| **Data** | `non_public_metrics.impression_count` requires user auth |

### Rate Limit Consideration
Basic tier: ~10,000 tweet reads/month
At 4 reads/hour × 24 hours × 30 days = 2,880 requests/user/month

## Running the Demo

### Requirements
- Xcode 15+
- iOS 16.1+ deployment target
- iPhone 14 Pro or newer (for actual Dynamic Island)

### Steps
1. Open `StarCyCreatorAnalytics.xcodeproj`
2. Select a device/simulator
3. Build and run
4. Tap "Start Live Activity"

### Note on Simulator
The Dynamic Island **does not render** in Simulator. You'll see the Lock Screen presentation instead. For full testing, use a physical device.

## Integration Guide

To integrate into StarCy's existing app:

1. **Add the Widget Extension** to your Xcode project
2. **Include `CreatorAnalyticsAttributes.swift`** in both targets
3. **Import `LiveActivityManager`** in your app code
4. **Call the API**:

```swift
// Start
try LiveActivityManager.shared.start(
    handle: user.xHandle,
    initialState: analyticsData.toContentState()
)

// Update (when new data arrives)
await LiveActivityManager.shared.update(with: newState)

// Stop
await LiveActivityManager.shared.stop()
```

5. **Add to Info.plist**:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## File Structure

```
StarCyCreatorAnalytics/
├── StarCyCreatorAnalytics/
│   ├── StarCyCreatorAnalyticsApp.swift
│   ├── ContentView.swift
│   ├── LiveActivityManager.swift
│   ├── MockAnalytics.swift
│   └── CreatorAnalyticsAttributes.swift  ← Shared
│
├── CreatorAnalyticsWidget/
│   ├── CreatorAnalyticsWidgetBundle.swift
│   ├── CreatorAnalyticsLiveActivity.swift
│   └── CreatorAnalyticsAttributes.swift  ← Shared
│
└── README.md
```

## License

MIT
```
