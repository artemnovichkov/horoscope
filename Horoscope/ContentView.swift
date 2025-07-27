//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import FoundationModels
import ZodiacKit

struct ContentView: View {
    @AppStorage("username") private var username: String = "artemnovichkov"
    @State private var viewModel = HoroscopeViewModel()

    var body: some View {
        NavigationStack {
            content
                .overlay {
                    overlayContent
                }
                .navigationTitle("Horoscope")
                .navigationSubtitle("for developers")
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
                VStack(alignment: .leading, spacing: 8) {
                    if let sign = viewModel.horoscope?.sign, let zodiacSign = Western(rawValue: sign.lowercased()) {
                        Text("Your Horoscope Sign:")
                            .font(.headline)
                        Text(zodiacSign.emoji + " " + zodiacSign.name)
                            .font(.largeTitle.bold())
                            .transition(.opacity)
                    }
                    if let message = viewModel.horoscope?.message {
                        Text(message)
                            .font(.body)
                            .transition(.opacity)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            }
            .padding(.horizontal)
        }
    }

    @ToolbarContentBuilder
    private var primaryActionToolbar: some ToolbarContent {
        if !viewModel.isLoading, let sign = viewModel.horoscope?.sign, let message = viewModel.horoscope?.message {
            ToolbarItemGroup(placement: .primaryAction) {
                ShareLink(item: "\(sign.capitalized) horoscope for today: \(message)")
            }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        if let unavailableReason = viewModel.unavailableReason {
            let text = switch unavailableReason {
            case .appleIntelligenceNotEnabled:
                "Apple Intelligence is not enabled. Please enable it in Settings."
            case .deviceNotEligible:
                "This device is not eligible for Apple Intelligence. Please use a compatible device."
            case .modelNotReady:
                "The language model is not ready yet. Please try again later."
            @unknown default:
                "The language model is unavailable for an unknown reason."
            }
            ContentUnavailableView(text, systemImage: "apple.intelligence.badge.xmark")
        }
        else if let error = viewModel.error {
            ContentUnavailableView(error.localizedDescription,
                                   systemImage: "apple.intelligence.badge.xmark")
            .transition(.opacity)
        } else if viewModel.isLoading && viewModel.horoscope == nil {
            ProgressView("Generating Horoscope...")
                .transition(.opacity)
        }
    }

    @ToolbarContentBuilder
    private var actionsToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: placement) {
            TextField("GitHub username", text: $username)
                .padding(.horizontal)
                .disabled(viewModel.isLoading || viewModel.unavailableReason != nil)
            Spacer()
            Button {
                viewModel.generate(username: username)
            }
            label: {
                Label("Generate", systemImage: "wand.and.sparkles")
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
