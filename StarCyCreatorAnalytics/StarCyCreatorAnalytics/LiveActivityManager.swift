import ActivityKit
import Combine
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published private(set) var isActive = false
    private var currentActivity: Activity<CreatorAnalyticsAttributes>?

    private init() {}

    func start(handle: String, initialState: CreatorAnalyticsAttributes.ContentState) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notAuthorized
        }

        let attributes = CreatorAnalyticsAttributes(handle: handle)
        let content = ActivityContent(state: initialState, staleDate: nil)
        let activity = try Activity.request(attributes: attributes, content: content)
        currentActivity = activity
        isActive = true
    }

    func update(with state: CreatorAnalyticsAttributes.ContentState) async {
        guard let activity = currentActivity else { return }
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.update(content)
    }

    func stop() async {
        guard let activity = currentActivity else { return }
        let finalState = activity.content.state
        let content = ActivityContent(state: finalState, staleDate: nil)
        await activity.end(content, dismissalPolicy: .immediate)
        currentActivity = nil
        isActive = false
    }
}

enum LiveActivityError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Live Activities are not enabled. Check Settings > StarCy."
        }
    }
}
