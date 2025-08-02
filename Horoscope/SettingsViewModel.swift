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
/// The view model uses `NotificationsService` for all notification-related operations.
@Observable
final class SettingsViewModel {
    var notificationsEnabled = false
    var notificationTime: Date = .now
    private(set) var authorizationStatus: UNAuthorizationStatus? = nil

    @ObservationIgnored
    private lazy var notificationsService = NotificationsService()
    @ObservationIgnored
    private var notificationsEnabledStreamTask: Task<Void, Error>?
    @ObservationIgnored
    private var notificationTimeStreamTask: Task<Void, Never>?

    func onAppear() {
        Task {
            let settings = await notificationsService.notificationSettings()
            authorizationStatus = settings.authorizationStatus

            if settings.authorizationStatus == .authorized {
                for request in await notificationsService.pendingNotificationRequests() {
                    guard request.identifier == NotificationsService.Constants.dailyNotificationIdentifier else {
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
                        authorizationStatus = await notificationsService.notificationSettings().authorizationStatus
                        if authorizationStatus == .notDetermined {
                            let granted = try await notificationsService.requestAuthorization()
                            if granted {
                                notificationTime = .now
                            }
                        }
                    } else {
                        notificationsService.removePendingNotificationRequests()
                    }
                }
            }

            let notificationTimeStream = Observations {
                self.notificationTime
            }

            notificationTimeStreamTask = Task {
                for await newTime in notificationTimeStream {
                    notificationsService.scheduleNotification(date: newTime)
                }
            }
        }
    }

    func onDisappear()  {
        notificationsEnabledStreamTask?.cancel()
        notificationTimeStreamTask?.cancel()
    }
}
