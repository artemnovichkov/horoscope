import NotificationsClient
import UserNotifications

public extension NotificationsClient {
    static let live = NotificationsClient(
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        },
        authorizationStatus: {
            await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        },
        pendingNotificationRequests: {
            await UNUserNotificationCenter.current().pendingNotificationRequests()
        },
        scheduleNotification: { date in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyNotificationIdentifier])

            let content = UNMutableNotificationContent()
            content.title = "Horoscope"
            content.body = "Check your daily horoscope!"
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            let request = UNNotificationRequest(identifier: dailyNotificationIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        },
        removePendingNotificationRequests: {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyNotificationIdentifier])
        }
    )
}
