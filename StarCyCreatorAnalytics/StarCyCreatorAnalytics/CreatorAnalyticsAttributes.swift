import ActivityKit
import SwiftUI
import Foundation

// MARK: - Activity Attributes

struct CreatorAnalyticsAttributes: ActivityAttributes {
    let handle: String

    struct ContentState: Codable, Hashable {
        let primaryMetric: PrimaryMetricType
        let tweetPreview: String
        let tweetAge: String
        let engagementRate: Double
        let erBaselineMultiplier: Double
        let impressions: Int
        let impressionsWindow: String
        let followerDelta: Int
        let followerWindow: String
        let velocityMultiplier: Double?
        let linkClicks: Int?
        let linkClicksMultiplier: Double?
        let isOutperforming: Bool
        let whyShown: String
    }
}

// MARK: - Primary Metric Type

enum PrimaryMetricType: String, Codable, Hashable {
    case engagementRate
    case trending
    case reachMilestone
    case followerMomentum
    case linkClicks

    var compactIcon: String {
        switch self {
        case .engagementRate: return "flame.fill"
        case .trending: return "chart.line.uptrend.xyaxis"
        case .reachMilestone: return "eye.fill"
        case .followerMomentum: return "person.badge.plus"
        case .linkClicks: return "link"
        }
    }

    var positiveColor: Color {
        switch self {
        case .engagementRate: return .orange
        case .trending: return .cyan
        case .reachMilestone: return .cyan
        case .followerMomentum: return .green
        case .linkClicks: return .blue
        }
    }
}
