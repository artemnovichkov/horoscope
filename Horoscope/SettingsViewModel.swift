//
//  Created by Artem Novichkov on 01.08.2025.
//
import Foundation
import UserNotifications
import SwiftUI

/// A view model that manages user notification settings for the Horoscope app.
///
/// `SettingsViewModel` handles the following responsibilities:
/// - Tracking whether daily notifications are enabled.
/// - Monitoring changes to the notification time.
/// - Requesting notification permissions from the user.
/// - Scheduling and canceling daily local notifications based on user preferences.
///
/// When the view appears, it retrieves the current notification settings, checks for any
/// pending notification requests, and restores the UI state accordingly. It also sets up
/// observation streams to reactively respond to changes in `notificationsEnabled` and `notificationTime`.
///
/// Notification permissions are automatically requested when enabling notifications, and
/// pending notifications are removed when the setting is turned off. If the time is updated,
/// a new notification is scheduled.
///
/// The view model uses `UNUserNotificationCenter` for all notification-related operations.
@Observable
final class SettingsViewModel {
    private enum Constants {
        static let dailyNotificationIdentifier = "dailyNotification"
    }
    var notificationsEnabled = false
    var notificationTime: Date = .now

    private(set) var authorizationStatus: UNAuthorizationStatus? = nil
    private var userNotificationCenter: UNUserNotificationCenter = .current()
    private var notificationsEnabledStreamTask: Task<Void, Error>?
    private var notificationTimeStreamTask: Task<Void, Never>?

    func onAppear() {
        Task {
            let settings = await userNotificationCenter.notificationSettings()
            authorizationStatus = settings.authorizationStatus

            if settings.authorizationStatus == .authorized {
                for request in await userNotificationCenter.pendingNotificationRequests() {
                    guard request.identifier == Constants.dailyNotificationIdentifier else {
                        break
                    }
                    if let calendarNotificationTrigger = request.trigger as? UNCalendarNotificationTrigger,
                       let date = calendarNotificationTrigger.nextTriggerDate() {
                        notificationsEnabled = true
                        notificationTime = date
                    }
                }
            } else {
                notificationsEnabled = false
            }

            let notificationsEnabledStream = Observations {
                self.notificationsEnabled
            }
            notificationsEnabledStreamTask = Task {
                for await notificationsEnabled in notificationsEnabledStream {
                    if notificationsEnabled {
                        authorizationStatus = await userNotificationCenter.notificationSettings().authorizationStatus
                        if authorizationStatus == .notDetermined {
                            let granted = try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                            if granted {
                                notificationTime = .now
                            }
                        }
                    } else {
                        removePendingNotificationRequests()
                    }
                }
            }

            let notificationTimeStream = Observations {
                self.notificationTime
            }

            notificationTimeStreamTask = Task {
                for await newTime in notificationTimeStream {
                    scheduleNotification(date: newTime)
                }
            }
        }
    }

    func onDisappear()  {
        notificationsEnabledStreamTask?.cancel()
        notificationTimeStreamTask?.cancel()
    }

    // MARK: - Private

    private func scheduleNotification(date: Date) {
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

    private func removePendingNotificationRequests() {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.dailyNotificationIdentifier])
    }
}
