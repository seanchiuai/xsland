import Foundation

struct MockAnalytics {

    static func randomState() -> CreatorAnalyticsAttributes.ContentState {
        let scenarios: [() -> CreatorAnalyticsAttributes.ContentState] = [
            // Good scenarios
            erSpikeScenario,
            trendingScenario,
            reachMilestoneScenario,
            followerMomentumScenario,
            linkClickScenario,
            // Bad scenarios
            erFlopScenario,
            lowReachScenario,
            followerLossScenario,
            linkFlopScenario
        ]
        return scenarios.randomElement()!()
    }

    // MARK: - Outperforming Scenarios

    private static func erSpikeScenario() -> CreatorAnalyticsAttributes.ContentState {
        let er = Double.random(in: 5.0...9.0)
        let multiplier = Double.random(in: 1.5...3.0)
        let impressions = Int.random(in: 5_000...50_000)
        let age = randomAge()

        return .init(
            primaryMetric: .engagementRate,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(er),
            erBaselineMultiplier: round1(multiplier),
            impressions: impressions,
            impressionsWindow: age,
            followerDelta: Int.random(in: 5...60),
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: true,
            whyShown: "Engagement rate is \(fmt1(multiplier))× your usual"
        )
    }

    private static func trendingScenario() -> CreatorAnalyticsAttributes.ContentState {
        let velocity = Double.random(in: 1.8...4.0)
        let impressions = Int.random(in: 3_000...25_000)
        let er = Double.random(in: 3.5...7.0)
        let age = "\(Int.random(in: 5...30))m"

        return .init(
            primaryMetric: .trending,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(er),
            erBaselineMultiplier: Double.random(in: 1.0...2.0),
            impressions: impressions,
            impressionsWindow: age,
            followerDelta: Int.random(in: 0...20),
            followerWindow: "2h",
            velocityMultiplier: round1(velocity),
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: true,
            whyShown: "Reaching people \(fmt1(velocity))× faster than your typical tweet"
        )
    }

    private static func reachMilestoneScenario() -> CreatorAnalyticsAttributes.ContentState {
        let milestones = [10_000, 25_000, 50_000, 100_000]
        let impressions = milestones.randomElement()!
        let multiplier = Double.random(in: 2.0...10.0)
        let er = Double.random(in: 2.5...6.0)
        let age = randomAge()

        return .init(
            primaryMetric: .reachMilestone,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(er),
            erBaselineMultiplier: round1(multiplier),
            impressions: impressions,
            impressionsWindow: age,
            followerDelta: Int.random(in: 5...80),
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: true,
            whyShown: "\(formatNumber(impressions)) impressions — \(Int(multiplier))× your baseline"
        )
    }

    private static func followerMomentumScenario() -> CreatorAnalyticsAttributes.ContentState {
        let followers = Int.random(in: 20...100)
        let multiplier = Double.random(in: 2.0...5.0)

        return .init(
            primaryMetric: .followerMomentum,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: randomAge(),
            engagementRate: round1(Double.random(in: 3.0...7.0)),
            erBaselineMultiplier: Double.random(in: 1.0...2.0),
            impressions: Int.random(in: 15_000...80_000),
            impressionsWindow: "2h",
            followerDelta: followers,
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: true,
            whyShown: "+\(followers) followers in 2h is \(fmt1(multiplier))× your usual pace"
        )
    }

    private static func linkClickScenario() -> CreatorAnalyticsAttributes.ContentState {
        let clicks = Int.random(in: 50...500)
        let multiplier = Double.random(in: 2.0...5.0)
        let age = randomAge()

        return .init(
            primaryMetric: .linkClicks,
            tweetPreview: mockLinkPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(Double.random(in: 2.5...5.0)),
            erBaselineMultiplier: Double.random(in: 1.0...1.5),
            impressions: Int.random(in: 8_000...40_000),
            impressionsWindow: age,
            followerDelta: Int.random(in: 2...30),
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: clicks,
            linkClicksMultiplier: round1(multiplier),
            isOutperforming: true,
            whyShown: "Link clicks are \(fmt1(multiplier))× your usual for link tweets"
        )
    }

    // MARK: - Underperforming Scenarios

    private static func erFlopScenario() -> CreatorAnalyticsAttributes.ContentState {
        let er = Double.random(in: 0.3...1.2)
        let multiplier = Double.random(in: 0.2...0.5)
        let impressions = Int.random(in: 500...5_000)
        let age = randomAge()

        return .init(
            primaryMetric: .engagementRate,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(er),
            erBaselineMultiplier: round1(multiplier),
            impressions: impressions,
            impressionsWindow: age,
            followerDelta: Int.random(in: -5...2),
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: false,
            whyShown: "Engagement rate is \(fmt1(multiplier))× your usual — consider what's different"
        )
    }

    private static func lowReachScenario() -> CreatorAnalyticsAttributes.ContentState {
        let impressions = Int.random(in: 200...2_000)
        let multiplier = Double.random(in: 0.1...0.4)
        let age = randomAge()

        return .init(
            primaryMetric: .reachMilestone,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(Double.random(in: 0.5...2.0)),
            erBaselineMultiplier: round1(multiplier),
            impressions: impressions,
            impressionsWindow: age,
            followerDelta: Int.random(in: -3...1),
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: false,
            whyShown: "Only \(formatNumber(impressions)) impressions — \(fmt1(multiplier))× your baseline reach"
        )
    }

    private static func followerLossScenario() -> CreatorAnalyticsAttributes.ContentState {
        let lost = Int.random(in: 8...50)
        let multiplier = Double.random(in: 2.0...5.0)

        return .init(
            primaryMetric: .followerMomentum,
            tweetPreview: mockPosts.randomElement()!,
            tweetAge: randomAge(),
            engagementRate: round1(Double.random(in: 0.5...2.0)),
            erBaselineMultiplier: round1(Double.random(in: 0.3...0.6)),
            impressions: Int.random(in: 10_000...60_000),
            impressionsWindow: "4h",
            followerDelta: -lost,
            followerWindow: "4h",
            velocityMultiplier: nil,
            linkClicks: nil,
            linkClicksMultiplier: nil,
            isOutperforming: false,
            whyShown: "Lost \(lost) followers in 4h — \(fmt1(multiplier))× your usual churn"
        )
    }

    private static func linkFlopScenario() -> CreatorAnalyticsAttributes.ContentState {
        let clicks = Int.random(in: 3...15)
        let multiplier = Double.random(in: 0.1...0.4)
        let age = randomAge()

        return .init(
            primaryMetric: .linkClicks,
            tweetPreview: mockLinkPosts.randomElement()!,
            tweetAge: age,
            engagementRate: round1(Double.random(in: 1.0...2.5)),
            erBaselineMultiplier: Double.random(in: 0.5...0.8),
            impressions: Int.random(in: 2_000...10_000),
            impressionsWindow: age,
            followerDelta: Int.random(in: -2...3),
            followerWindow: "2h",
            velocityMultiplier: nil,
            linkClicks: clicks,
            linkClicksMultiplier: round1(multiplier),
            isOutperforming: false,
            whyShown: "Only \(clicks) link clicks — \(fmt1(multiplier))× your usual CTR"
        )
    }

    // MARK: - Helpers

    private static func randomAge() -> String {
        ["8m", "15m", "25m", "45m", "1h", "2h", "3h"].randomElement()!
    }

    private static func round1(_ v: Double) -> Double {
        (v * 10).rounded() / 10
    }

    private static func fmt1(_ v: Double) -> String {
        String(format: "%.1f", (v * 10).rounded() / 10)
    }

    private static func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", Double(num) / 1_000)
        }
        return "\(num)"
    }

    static let mockPosts = [
        "Just shipped the new dashboard feature and the response has been insane",
        "Thread: What I learned after mass losing 10K followers in a week",
        "Hot take: AI won't replace developers, but developers who use AI will replace those who don't",
        "Unpopular opinion about startups — most founders are building solutions to problems nobody has",
        "3 things nobody tells you about growing on X that actually matter",
        "This changed how I think about content creation forever",
        "Why most founders get product-market fit completely wrong"
    ]

    static let mockLinkPosts = [
        "New blog post: How to build a personal brand on X without being cringe",
        "Just published: Why your engagement rate matters more than follower count",
        "Read this before you quit your job to become a creator — lessons from 2 years in",
        "Deep dive into how the X algorithm actually works in 2026",
        "My latest writeup on building in public — the good, the bad, and the ugly"
    ]
}
