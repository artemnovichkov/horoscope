//
//  Created by Artem Novichkov on 01.08.2025.
//

import SwiftUI
import UserNotifications

/// A view that presents user settings for managing notifications.
///
/// The `SettingsView` allows the user to enable or disable notifications and configure the notification time.
/// If the notification permission is denied, it offers a way to open system settings to adjust notification preferences.
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(.notifications) {
                    Toggle(.allowNotifications, isOn: $viewModel.notificationsEnabled)
                        .disabled(viewModel.authorizationStatus == .denied)
                    if viewModel.notificationsEnabled {
                        DatePicker(.time, selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                    }
                    if let authorizationStatus = viewModel.authorizationStatus {
                        switch authorizationStatus {
                        case .denied:
                            Text(.notificationsDenied)
                                .foregroundColor(.red)
                            #if os(macOS)
                            Button("Open Settings") {
                                let notificationsPath = "x-apple.systempreferences:com.apple.Notifications-Settings.extension"
                                let bundleId = Bundle.main.bundleIdentifier
                                if let url = URL(string: "\(notificationsPath)?id=\(bundleId ?? "")") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            #else
                            Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                            #endif

                        default:
                            EmptyView()
                        }
                    }
                }
            }
            .frame(maxWidth: 400)
            #if os(macOS)
            .padding(.bottom)
            #endif
            .navigationTitle(.settings)
            .colorScheme(.dark)

        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

#Preview {
    SettingsView()
}
