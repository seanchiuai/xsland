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
                    // Profile circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("S")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        )
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("StarCy")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                CompactLeadingView(context: context)
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
        }
    }
}

// MARK: - Compact Views

private struct CompactLeadingView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>

    var body: some View {
        Image(systemName: context.state.isOutperforming
              ? context.state.primaryMetric.compactIcon
              : "arrow.down.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle((context.state.isOutperforming ? context.state.primaryMetric.positiveColor : Color(red: 1, green: 0.23, blue: 0.19)))
    }
}

private struct CompactTrailingView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    private var accent: Color { (context.state.isOutperforming ? context.state.primaryMetric.positiveColor : Color(red: 1, green: 0.23, blue: 0.19)) }

    var body: some View {
        switch context.state.primaryMetric {
        case .engagementRate:
            HStack(spacing: 2) {
                Text(formatER(context.state.engagementRate))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                directionArrow
            }
        case .trending:
            HStack(spacing: 2) {
                Text(formatMultiplier(context.state.velocityMultiplier ?? 1.0))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                directionArrow
            }
        case .reachMilestone:
            HStack(spacing: 2) {
                Text(formatNumber(context.state.impressions))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                directionArrow
            }
        case .followerMomentum:
            HStack(spacing: 1) {
                Text(context.state.isOutperforming ? "+\(context.state.followerDelta)" : "\(context.state.followerDelta)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Image(systemName: "person.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
        case .linkClicks:
            HStack(spacing: 2) {
                Text(formatMultiplier(context.state.linkClicksMultiplier ?? 1.0))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                directionArrow
            }
        }
    }

    private var directionArrow: some View {
        Image(systemName: context.state.isOutperforming ? "arrow.up.right" : "arrow.down.right")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Color(context.state.isOutperforming ? .green : .red))
    }
}

// MARK: - Minimal View

private struct MinimalView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>

    var body: some View {
        Image(systemName: context.state.isOutperforming
              ? context.state.primaryMetric.compactIcon
              : "exclamationmark.triangle.fill")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle((context.state.isOutperforming ? context.state.primaryMetric.positiveColor : Color(red: 1, green: 0.23, blue: 0.19)))
    }
}

// MARK: - Expanded Bottom View (notification-center style)

private struct ExpandedBottomView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    private var accent: Color { context.state.isOutperforming ? context.state.primaryMetric.positiveColor : Color(red: 1, green: 0.23, blue: 0.19) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Headline row — the trigger message
            Text(headlineText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)

            // Row 1: Post preview
            HStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                Text(context.state.tweetPreview)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(context.state.tweetAge + " ago")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            // Row 2: Primary metric detail
            HStack(spacing: 8) {
                Image(systemName: context.state.primaryMetric.compactIcon)
                    .font(.system(size: 13))
                    .foregroundStyle(accent)
                    .frame(width: 18)
                Text(primaryDetailText)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(primaryDetailValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            // Row 3: Secondary metric
            HStack(spacing: 8) {
                Image(systemName: secondaryIcon)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                Text(secondaryDetailText)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(secondaryDetailValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
        .padding(.top, 2)
    }

    // MARK: - Computed text

    private var headlineText: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate:
            return s.isOutperforming
                ? "Your post is getting great engagement"
                : "Your post is underperforming"
        case .trending:
            return "Your post is trending right now"
        case .reachMilestone:
            return s.isOutperforming
                ? "Your post hit \(formatNumber(s.impressions)) impressions"
                : "Your post isn't reaching many people"
        case .followerMomentum:
            return s.isOutperforming
                ? "You're gaining followers fast"
                : "You're losing followers"
        case .linkClicks:
            return s.isOutperforming
                ? "People are clicking your link"
                : "Your link isn't getting clicks"
        }
    }

    private var primaryDetailText: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate:
            return "Engagement rate"
        case .trending:
            return "Velocity"
        case .reachMilestone:
            return "Impressions"
        case .followerMomentum:
            return "Followers (\(s.followerWindow))"
        case .linkClicks:
            return "Link clicks"
        }
    }

    private var primaryDetailValue: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate:
            return "\(formatER(s.engagementRate)) · \(formatMultiplier(s.erBaselineMultiplier)) usual"
        case .trending:
            return "\(formatMultiplier(s.velocityMultiplier ?? 1.0)) faster"
        case .reachMilestone:
            return "\(formatNumber(s.impressions)) · \(formatMultiplier(s.erBaselineMultiplier)) usual"
        case .followerMomentum:
            return "\(s.followerDelta >= 0 ? "+" : "")\(s.followerDelta)"
        case .linkClicks:
            return "\(s.linkClicks ?? 0) · \(formatMultiplier(s.linkClicksMultiplier ?? 1.0)) usual"
        }
    }

    private var secondaryIcon: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate, .linkClicks:
            return "eye.fill"
        case .trending:
            return "flame.fill"
        case .reachMilestone, .followerMomentum:
            return "hand.thumbsup.fill"
        }
    }

    private var secondaryDetailText: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate, .linkClicks:
            return "Impressions (\(s.impressionsWindow))"
        case .trending:
            return "Engagement rate"
        case .reachMilestone, .followerMomentum:
            return "Engagement rate"
        }
    }

    private var secondaryDetailValue: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate, .linkClicks:
            return formatNumber(s.impressions)
        case .trending:
            return formatER(s.engagementRate)
        case .reachMilestone, .followerMomentum:
            return formatER(s.engagementRate)
        }
    }
}

// MARK: - Lock Screen View

private struct LockScreenView: View {
    let context: ActivityViewContext<CreatorAnalyticsAttributes>
    private var accent: Color { context.state.isOutperforming ? context.state.primaryMetric.positiveColor : Color(red: 1, green: 0.23, blue: 0.19) }

    var body: some View {
        HStack(spacing: 12) {
            // Profile circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Text("S")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                // App name + time
                HStack {
                    Text("StarCy")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(context.state.tweetAge + " ago")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                // Headline
                Text(lockScreenHeadline)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)

                // Post preview
                Text(context.state.tweetPreview)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .activityBackgroundTint(.black.opacity(0.85))
    }

    private var lockScreenHeadline: String {
        let s = context.state
        switch s.primaryMetric {
        case .engagementRate:
            return s.isOutperforming
                ? "Engagement is \(formatMultiplier(s.erBaselineMultiplier)) your usual"
                : "Engagement dropped to \(formatER(s.engagementRate))"
        case .trending:
            return "Post is trending \(formatMultiplier(s.velocityMultiplier ?? 1.0)) faster"
        case .reachMilestone:
            return s.isOutperforming
                ? "Hit \(formatNumber(s.impressions)) impressions"
                : "Only \(formatNumber(s.impressions)) impressions so far"
        case .followerMomentum:
            return s.isOutperforming
                ? "+\(s.followerDelta) followers in \(s.followerWindow)"
                : "\(s.followerDelta) followers in \(s.followerWindow)"
        case .linkClicks:
            return s.isOutperforming
                ? "\(s.linkClicks ?? 0) link clicks — \(formatMultiplier(s.linkClicksMultiplier ?? 1.0)) usual"
                : "Only \(s.linkClicks ?? 0) link clicks"
        }
    }
}

// MARK: - Helpers

private func formatER(_ rate: Double) -> String {
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

private func formatMultiplier(_ m: Double) -> String {
    String(format: "%.1f×", m)
}

// MARK: - Previews

private let erSpikeState = CreatorAnalyticsAttributes.ContentState(
    primaryMetric: .engagementRate,
    tweetPreview: "Just shipped the new dashboard feature and the response has been insane",
    tweetAge: "45m",
    engagementRate: 6.2,
    erBaselineMultiplier: 2.0,
    impressions: 18400,
    impressionsWindow: "45m",
    followerDelta: 24,
    followerWindow: "2h",
    velocityMultiplier: nil,
    linkClicks: nil,
    linkClicksMultiplier: nil,
    isOutperforming: true,
    whyShown: "Engagement rate is 2.0× your usual"
)

private let underperformingState = CreatorAnalyticsAttributes.ContentState(
    primaryMetric: .engagementRate,
    tweetPreview: "Unpopular opinion about startups — most founders are building solutions to problems nobody has",
    tweetAge: "2h",
    engagementRate: 0.8,
    erBaselineMultiplier: 0.3,
    impressions: 2100,
    impressionsWindow: "2h",
    followerDelta: -3,
    followerWindow: "2h",
    velocityMultiplier: nil,
    linkClicks: nil,
    linkClicksMultiplier: nil,
    isOutperforming: false,
    whyShown: "Engagement rate is 0.3× your usual — consider what's different"
)

private let followerLossState = CreatorAnalyticsAttributes.ContentState(
    primaryMetric: .followerMomentum,
    tweetPreview: "Hot take: AI won't replace developers, but developers who use AI will replace those who don't",
    tweetAge: "4h",
    engagementRate: 1.2,
    erBaselineMultiplier: 0.4,
    impressions: 45000,
    impressionsWindow: "4h",
    followerDelta: -18,
    followerWindow: "4h",
    velocityMultiplier: nil,
    linkClicks: nil,
    linkClicksMultiplier: nil,
    isOutperforming: false,
    whyShown: "Lost 18 followers in 4h — unusual for your account"
)

#Preview("Compact: ER Spike", as: .dynamicIsland(.compact), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    erSpikeState
}

#Preview("Expanded: ER Spike", as: .dynamicIsland(.expanded), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    erSpikeState
}

#Preview("Compact: Underperforming", as: .dynamicIsland(.compact), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    underperformingState
}

#Preview("Expanded: Underperforming", as: .dynamicIsland(.expanded), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    underperformingState
}

#Preview("Expanded: Follower Loss", as: .dynamicIsland(.expanded), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    followerLossState
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    erSpikeState
}

#Preview("Minimal: Warning", as: .dynamicIsland(.minimal), using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    underperformingState
}

#Preview("Lock Screen", as: .content, using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    erSpikeState
}

#Preview("Lock Screen: Underperforming", as: .content, using: CreatorAnalyticsAttributes(handle: "demo_creator")) {
    CreatorAnalyticsLiveActivity()
} contentStates: {
    underperformingState
}
