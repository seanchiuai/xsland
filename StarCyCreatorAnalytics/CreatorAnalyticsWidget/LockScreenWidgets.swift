import SwiftUI
import WidgetKit

// MARK: - Shared Mock Data for Widgets

private struct WidgetMockData {
    static let followers = 12_847
    static let impressions = 34_200
    static let engagementRate = 5.3
}

// MARK: - Followers Widget

struct FollowersEntry: TimelineEntry {
    let date: Date
    let followers: Int
}

struct FollowersProvider: TimelineProvider {
    func placeholder(in context: Context) -> FollowersEntry {
        FollowersEntry(date: .now, followers: 12_847)
    }

    func getSnapshot(in context: Context, completion: @escaping (FollowersEntry) -> Void) {
        completion(FollowersEntry(date: .now, followers: WidgetMockData.followers))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FollowersEntry>) -> Void) {
        let entry = FollowersEntry(date: .now, followers: WidgetMockData.followers)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct FollowersWidget: Widget {
    let kind = "FollowersWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FollowersProvider()) { entry in
            FollowersWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Followers")
        .description("Your current follower count.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private struct FollowersWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: FollowersEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            FollowersCircularView(count: entry.followers)
        case .accessoryRectangular:
            FollowersRectangularView(count: entry.followers)
        case .accessoryInline:
            Label("\(formatCompact(entry.followers)) followers", systemImage: "person.2.fill")
        default:
            Text(formatCompact(entry.followers))
        }
    }
}

private struct FollowersCircularView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 12, weight: .semibold))
                .widgetAccentable()
            Text(formatCompact(count))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
    }
}

private struct FollowersRectangularView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 18, weight: .semibold))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text(formatCompact(count))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("followers")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Impressions Widget

struct ImpressionsEntry: TimelineEntry {
    let date: Date
    let impressions: Int
}

struct ImpressionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ImpressionsEntry {
        ImpressionsEntry(date: .now, impressions: 34_200)
    }

    func getSnapshot(in context: Context, completion: @escaping (ImpressionsEntry) -> Void) {
        completion(ImpressionsEntry(date: .now, impressions: WidgetMockData.impressions))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ImpressionsEntry>) -> Void) {
        let entry = ImpressionsEntry(date: .now, impressions: WidgetMockData.impressions)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct ImpressionsWidget: Widget {
    let kind = "ImpressionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ImpressionsProvider()) { entry in
            ImpressionsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Impressions")
        .description("Today's impression count.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private struct ImpressionsWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ImpressionsEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            ImpressionsCircularView(count: entry.impressions)
        case .accessoryRectangular:
            ImpressionsRectangularView(count: entry.impressions)
        case .accessoryInline:
            Label("\(formatCompact(entry.impressions)) impressions", systemImage: "eye.fill")
        default:
            Text(formatCompact(entry.impressions))
        }
    }
}

private struct ImpressionsCircularView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: "eye.fill")
                .font(.system(size: 12, weight: .semibold))
                .widgetAccentable()
            Text(formatCompact(count))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
    }
}

private struct ImpressionsRectangularView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "eye.fill")
                .font(.system(size: 18, weight: .semibold))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text(formatCompact(count))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("impressions today")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Engagement Rate Widget

struct EngagementRateEntry: TimelineEntry {
    let date: Date
    let rate: Double
}

struct EngagementRateProvider: TimelineProvider {
    func placeholder(in context: Context) -> EngagementRateEntry {
        EngagementRateEntry(date: .now, rate: 5.3)
    }

    func getSnapshot(in context: Context, completion: @escaping (EngagementRateEntry) -> Void) {
        completion(EngagementRateEntry(date: .now, rate: WidgetMockData.engagementRate))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EngagementRateEntry>) -> Void) {
        let entry = EngagementRateEntry(date: .now, rate: WidgetMockData.engagementRate)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct EngagementRateWidget: Widget {
    let kind = "EngagementRateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EngagementRateProvider()) { entry in
            EngagementRateWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Engagement Rate")
        .description("Your current engagement rate.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private struct EngagementRateWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: EngagementRateEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            EngagementRateCircularView(rate: entry.rate)
        case .accessoryRectangular:
            EngagementRateRectangularView(rate: entry.rate)
        case .accessoryInline:
            Label("\(String(format: "%.1f", entry.rate))% ER", systemImage: "flame.fill")
        default:
            Text("\(String(format: "%.1f", entry.rate))%")
        }
    }
}

private struct EngagementRateCircularView: View {
    let rate: Double

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12, weight: .semibold))
                .widgetAccentable()
            Text("\(String(format: "%.1f", rate))%")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
    }
}

private struct EngagementRateRectangularView: View {
    let rate: Double

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 18, weight: .semibold))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text("\(String(format: "%.1f", rate))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("engagement rate")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Shared Formatter

private func formatCompact(_ num: Int) -> String {
    if num >= 1_000_000 {
        return String(format: "%.1fM", Double(num) / 1_000_000)
    } else if num >= 100_000 {
        return String(format: "%.0fK", Double(num) / 1_000)
    } else if num >= 1_000 {
        return String(format: "%.1fK", Double(num) / 1_000)
    }
    return "\(num)"
}

// MARK: - Previews

#Preview("Followers Circular", as: .accessoryCircular) {
    FollowersWidget()
} timeline: {
    FollowersEntry(date: .now, followers: 12_847)
}

#Preview("Followers Rectangular", as: .accessoryRectangular) {
    FollowersWidget()
} timeline: {
    FollowersEntry(date: .now, followers: 12_847)
}

#Preview("Followers Inline", as: .accessoryInline) {
    FollowersWidget()
} timeline: {
    FollowersEntry(date: .now, followers: 12_847)
}

#Preview("Impressions Circular", as: .accessoryCircular) {
    ImpressionsWidget()
} timeline: {
    ImpressionsEntry(date: .now, impressions: 34_200)
}

#Preview("Impressions Rectangular", as: .accessoryRectangular) {
    ImpressionsWidget()
} timeline: {
    ImpressionsEntry(date: .now, impressions: 34_200)
}

#Preview("Engagement Circular", as: .accessoryCircular) {
    EngagementRateWidget()
} timeline: {
    EngagementRateEntry(date: .now, rate: 5.3)
}

#Preview("Engagement Rectangular", as: .accessoryRectangular) {
    EngagementRateWidget()
} timeline: {
    EngagementRateEntry(date: .now, rate: 5.3)
}
