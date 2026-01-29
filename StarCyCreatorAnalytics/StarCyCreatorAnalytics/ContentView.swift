import SwiftUI

struct ContentView: View {
    @StateObject private var activityManager = LiveActivityManager.shared
    @State private var currentState = MockAnalytics.randomState()
    @State private var errorMessage: String?

    private let handle = "demo_creator"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Current event card
                eventCard

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
                        Label("Simulate New Event", systemImage: "arrow.clockwise")
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

    private var eventCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Trigger type badge
            HStack {
                Image(systemName: currentState.primaryMetric.compactIcon)
                    .foregroundStyle(currentState.isOutperforming ? currentState.primaryMetric.positiveColor : .red)
                Text(triggerLabel)
                    .font(.caption.bold())
                    .foregroundStyle(currentState.isOutperforming ? currentState.primaryMetric.positiveColor : .red)
                Spacer()
                Text(currentState.tweetAge + " ago")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Tweet preview
            Text(currentState.tweetPreview)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            // Core trio
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Engagement")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f%%", currentState.engagementRate))
                            .font(.subheadline.bold())
                        Text("\(String(format: "%.1f", currentState.erBaselineMultiplier))× usual")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    Text("Impressions")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(formatNumber(currentState.impressions))
                        .font(.subheadline.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Followers")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("+\(currentState.followerDelta)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
            }

            // Conditional: link clicks
            if let clicks = currentState.linkClicks, clicks > 0 {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Link Clicks")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(formatNumber(clicks))
                                .font(.subheadline.bold())
                            if let m = currentState.linkClicksMultiplier {
                                Text("\(String(format: "%.1f", m))× usual")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    Spacer()
                }
            }

            // Velocity
            if let vel = currentState.velocityMultiplier {
                Divider()
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                    Text("Trending \(String(format: "%.1f", vel))× faster than usual")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }
            }

            Divider()

            // Why shown
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(currentState.whyShown)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var triggerLabel: String {
        switch currentState.primaryMetric {
        case .engagementRate: return "ER Spike"
        case .trending: return "Trending"
        case .reachMilestone: return "Reach Milestone"
        case .followerMomentum: return "Follower Momentum"
        case .linkClicks: return "Link Click Spike"
        }
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
