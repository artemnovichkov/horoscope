//
//  Created by Artem Novichkov on 01.08.2025.
//
import Foundation
import UserNotifications
import SwiftUI
import NotificationsClient
import NotificationsClientLive

@Observable
final class SettingsViewModel {
    var notificationsEnabled = false
    var notificationTime: Date = .now
    private(set) var authorizationStatus: UNAuthorizationStatus? = nil

    @ObservationIgnored
    private var notificationsClient: NotificationsClient
    @ObservationIgnored
    private var notificationsEnabledStreamTask: Task<Void, Error>?
    @ObservationIgnored
    private var notificationTimeStreamTask: Task<Void, Never>?

    init(notificationsClient: NotificationsClient = .live) {
        self.notificationsClient = notificationsClient
    }

    func onAppear() {
        Task {
            let status = await notificationsClient.authorizationStatus()
            authorizationStatus = status

            if status == .authorized {
                for request in await notificationsClient.pendingNotificationRequests() {
                    guard request.identifier == NotificationsClient.dailyNotificationIdentifier else {
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
                        authorizationStatus = await notificationsClient.authorizationStatus()
                        if authorizationStatus == .notDetermined {
                            let granted = try await notificationsClient.requestAuthorization()
                            if granted {
                                notificationTime = .now
                            }
                        }
                    } else {
                        notificationsClient.removePendingNotificationRequests()
                    }
                }
            }

            let notificationTimeStream = Observations {
                self.notificationTime
            }

            notificationTimeStreamTask = Task {
                for await newTime in notificationTimeStream {
                    notificationsClient.scheduleNotification(newTime)
                }
            }
        }
    }

    func onDisappear() {
        notificationsEnabledStreamTask?.cancel()
        notificationTimeStreamTask?.cancel()
    }
}
