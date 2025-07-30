//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import FoundationModels
import ZodiacKit
import TipKit

struct ContentView: View {
    @AppStorage("username") private var username: String = "artemnovichkov"
    @State private var viewModel = ContentViewModel()

    private let usernameTip = UsernameTip()
    private let shareTip = ShareTip()

    var body: some View {
        NavigationStack {
            content
                .overlay {
                    overlayContent
                }
                .navigationTitle(.horoscope)
                .navigationSubtitle(.forDevelopers)
                .toolbar {
                    primaryActionToolbar
                }
                .toolbar {
                    actionsToolbar
                }
                .animation(.easeOut, value: viewModel.horoscope)
                .animation(.easeOut, value: viewModel.isLoading)
                .onAppear {
                    viewModel.onAppear()
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
        if !viewModel.isLoading, let sign = viewModel.horoscope?.sign, let message = viewModel.horoscope?.message {
            ToolbarItemGroup(placement: .primaryAction) {
                ShareLink(item: "\(sign.capitalized) horoscope for today: \(message)") {
                    Image(systemName: "square.and.arrow.up")
                        .popoverTip(shareTip)
                }
            }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        if let unavailableReason = viewModel.unavailableReason {
            let text: LocalizedStringResource = switch unavailableReason {
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
        }
        else if let error = viewModel.error {
            ContentUnavailableView(error.localizedDescription,
                                   systemImage: "apple.intelligence.badge.xmark")
            .transition(.opacity)
            .sensoryFeedback(.error, trigger: viewModel.error != nil)
        } else if viewModel.isLoading && viewModel.horoscope == nil {
            ProgressView(.generatingHoroscope)
                .transition(.opacity)
                .sensoryFeedback(.impact, trigger: viewModel.isLoading)
        }
    }

    @ToolbarContentBuilder
    private var actionsToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: placement) {
            TextField(.githubUsername, text: $username)
                .keyboardType(.alphabet)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)
                .disabled(viewModel.isLoading || viewModel.unavailableReason != nil)
                .popoverTip(usernameTip)
            Spacer()
            Button {
                viewModel.generate(username: username)
            }
            label: {
                Label(.generate, systemImage: "wand.and.sparkles")
            }
            .disabled(viewModel.isLoading || viewModel.unavailableReason != nil || username.isEmpty)
        }
    }

    var placement: ToolbarItemPlacement {
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
