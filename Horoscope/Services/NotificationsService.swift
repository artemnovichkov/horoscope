//
//  Created by Artem Novichkov on 02.08.2025.
//

import UserNotifications

final class NotificationsService {
    enum Constants {
        static let dailyNotificationIdentifier = "dailyNotification"
    }

    private var userNotificationCenter: UNUserNotificationCenter = .current()

    func requestAuthorization() async throws -> Bool {
        try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func notificationSettings() async -> UNNotificationSettings {
        await userNotificationCenter.notificationSettings()
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await userNotificationCenter.pendingNotificationRequests()
    }

    func scheduleNotification(date: Date) {
        removePendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Horoscope"
        content.body = "Check your daily horoscope!"
        content.sound = .default

        let calendar = Calendar.current
        let triggerDate = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        let request = UNNotificationRequest(identifier: Constants.dailyNotificationIdentifier, content: content, trigger: trigger)

        userNotificationCenter.add(request)
    }

    func removePendingNotificationRequests() {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.dailyNotificationIdentifier])
    }
}
