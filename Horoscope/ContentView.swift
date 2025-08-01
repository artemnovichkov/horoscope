//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import FoundationModels
import ZodiacKit
import TipKit

struct ContentView: View {
    @AppStorage("username") private var username: String = ""
    @State private var viewModel = ContentViewModel()

    private let usernameTip = UsernameTip()
    private let shareTip = ShareTip()

    var body: some View {
        NavigationStack {
            content
                .overlay {
                    overlayContent
                        .transition(.opacity)
                        .sensoryFeedback(trigger: viewModel.overlayState) { _, newValue in
                            switch newValue {
                            case .normal:
                                nil
                            case .unavailable, .error:
                                .error
                            case .loading:
                                .success
                            }
                        }
                }
            #if os(visionOS)
                .navigationTitle(.horoscope)
            #else
                .navigationTitle(.horoscope)
                .navigationSubtitle(.forDevelopers)
            #endif
                .toolbar {
                    primaryActionToolbar
                }
                .toolbar {
                    actionsToolbar
                }
                .animation(.easeOut, value: viewModel.overlayState)
                .animation(.easeOut, value: viewModel.horoscope)
                .onAppear {
                    viewModel.onAppear(username: username)
                }
                .onOpenURL { url in
                    if url == .horoscopeURL, username.isEmpty == false {
                        viewModel.generate(username: username)
                    }
                }
                .sheet(isPresented: $viewModel.settingsOpened) {
                    SettingsView()
                }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var content: some View {
        ZStack {
            MeshGradient(width: 2, height: 2, points: [
                [0, 0], [1, 0],
                [0, 1], [1, 1]
            ], colors: [
                .indigo.opacity(0.3), .black,
                .black, .purple.opacity(0.3)
            ])
            .ignoresSafeArea()
            ScrollView {
                HoroscopePartialView(horoscope: viewModel.horoscope)
            }
            .padding(.horizontal)
        }
    }

    @ToolbarContentBuilder
    private var primaryActionToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            #if !os(macOS)
            Button {
                viewModel.settingsOpened.toggle()
            } label: {
                Label(.settings, systemImage: "gearshape")
            }
            #endif
            if viewModel.overlayState != .loading, let sign = viewModel.horoscope?.sign, let message = viewModel.horoscope?.message {
                ShareLink(item: "\(sign.capitalized) horoscope for today: \(message)") {
                    Image(systemName: "square.and.arrow.up")
                        .popoverTip(shareTip)
                }
            }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        switch viewModel.overlayState {
        case .normal:
            EmptyView()
        case .unavailable(let reason):
            let text: LocalizedStringResource = switch reason {
            case .appleIntelligenceNotEnabled:
                .appleIntelligenceNotEnabled
            case .deviceNotEligible:
                .deviceNotEligible
            case .modelNotReady:
                .modelNotReady
            @unknown default:
                .unknownReason
            }
            ContentUnavailableView(text, systemImage: "apple.intelligence.badge.xmark")
        case .loading:
            ProgressView(.generatingHoroscope)
        case .error(let string):
            ContentUnavailableView(string,
                                   systemImage: "xmark.circle")
        }
    }

    @ToolbarContentBuilder
    private var actionsToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: placement) {
            TextField(.githubUsername, text: $username)
            #if os(isOS)
                .keyboardType(.alphabet)
                .textInputAutocapitalization(.never)
            #endif
                .padding(.horizontal)
                .disabled(isDisabled)
                .popoverTip(usernameTip)
            Spacer()
            Button {
                viewModel.generate(username: username)
            }
            label: {
                Label(.generate, systemImage: "wand.and.sparkles")
            }
            .disabled(isDisabled || username.isEmpty)
        }
    }

    private var isDisabled: Bool {
        switch viewModel.overlayState {
        case .normal, .error:
            false
        case .unavailable, .loading:
            true
        }
    }

    private var placement: ToolbarItemPlacement {
        #if os(iOS)
        .bottomBar
        #else
        .automatic
        #endif
    }
}

#Preview {
    ContentView()
        .colorScheme(.dark)
}
