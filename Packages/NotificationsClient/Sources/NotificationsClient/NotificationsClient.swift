import UserNotifications

public struct NotificationsClient: Sendable {
    public nonisolated static let dailyNotificationIdentifier = "dailyNotification"

    public var requestAuthorization: @Sendable () async throws -> Bool
    public var authorizationStatus: @Sendable () async -> UNAuthorizationStatus
    public var pendingNotificationRequests: @Sendable () async -> [UNNotificationRequest]
    public var scheduleNotification: @Sendable (Date) -> Void
    public var removePendingNotificationRequests: @Sendable () -> Void

    public init(
        requestAuthorization: @escaping @Sendable () async throws -> Bool,
        authorizationStatus: @escaping @Sendable () async -> UNAuthorizationStatus,
        pendingNotificationRequests: @escaping @Sendable () async -> [UNNotificationRequest],
        scheduleNotification: @escaping @Sendable (Date) -> Void,
        removePendingNotificationRequests: @escaping @Sendable () -> Void
    ) {
        self.requestAuthorization = requestAuthorization
        self.authorizationStatus = authorizationStatus
        self.pendingNotificationRequests = pendingNotificationRequests
        self.scheduleNotification = scheduleNotification
        self.removePendingNotificationRequests = removePendingNotificationRequests
    }
}

#if DEBUG
public extension NotificationsClient {
    static let notDetermined = NotificationsClient(
        requestAuthorization: { true },
        authorizationStatus: { .notDetermined },
        pendingNotificationRequests: { [] },
        scheduleNotification: { _ in },
        removePendingNotificationRequests: {}
    )

    static let authorized = NotificationsClient(
        requestAuthorization: { true },
        authorizationStatus: { .authorized },
        pendingNotificationRequests: {
            let content = UNMutableNotificationContent()
            content.title = "Horoscope"
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(hour: 9, minute: 0),
                repeats: true
            )
            return [UNNotificationRequest(identifier: dailyNotificationIdentifier, content: content, trigger: trigger)]
        },
        scheduleNotification: { _ in },
        removePendingNotificationRequests: {}
    )

    static let denied = NotificationsClient(
        requestAuthorization: { false },
        authorizationStatus: { .denied },
        pendingNotificationRequests: { [] },
        scheduleNotification: { _ in },
        removePendingNotificationRequests: {}
    )
}
#endif
