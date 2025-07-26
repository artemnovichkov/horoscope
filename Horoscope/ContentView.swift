//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import FoundationModels
import ZodiacKit

struct ContentView: View {
    @AppStorage("username") private var username: String = "artemnovichkov"
    @State private var session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
                        """
                        Your job is to create a horoscope for developers.
                        Always use the fetchUserInfo tool to get zodiac sign and gender. 
                        Always use the fetchGithubInfo tool to get user info and repos from Github.
                        The horoscope must be funny and witty.
                        """
    }
    @State private var isLoading = false
    @State private var error: Error?
    @State private var horoscope: Horoscope.PartiallyGenerated?

    var body: some View {
        NavigationStack {
            content
                .overlay {
                    overlayContent
                }
                .navigationTitle("Developer Horoscope")
                .toolbar {
                    topToolbar
                }
                .toolbar {
                    bottomToolbar
                }
                .animation(.easeOut, value: horoscope)
                .onAppear {
                    session.prewarm()
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
                    if let sign = horoscope?.sign, let zodiacSign = Western(rawValue: sign.lowercased()) {
                        Text("Your Horoscope Sign:")
                            .font(.headline)
                        Text(zodiacSign.emoji + " " + zodiacSign.name)
                            .font(.largeTitle.bold())
                            .transition(.opacity)
                    }
                    if let message = horoscope?.message {
                        Text(message)
                            .font(.body)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }
    }

    @ToolbarContentBuilder
    private var topToolbar: some ToolbarContent {
        if !isLoading, let sign = horoscope?.sign, let message = horoscope?.message {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: "\(sign.capitalized) horoscope for today: \(message)")
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        if let error {
            ContentUnavailableView(error.localizedDescription,
                                   systemImage: "apple.intelligence.badge.xmark")
            .transition(.opacity)
        } else if isLoading && horoscope == nil {
            ProgressView("Generating Horoscope...")
                .transition(.opacity)
        }
    }

    @ToolbarContentBuilder
    private var bottomToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            TextField("GitHub username", text: $username)
                .padding(.horizontal)
                .disabled(isLoading)
        }
        ToolbarSpacer(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                Task { @MainActor in
                    horoscope = nil
                    error = nil
                    isLoading = true
                    await generateHoroscope()
                    isLoading = false
                    print(session.transcript)
                }
            }
            label: { Label("Generate", systemImage: "wand.and.sparkles") }
                .disabled(isLoading || username.isEmpty)
        }
    }

    private func generateHoroscope() async {
        do {
            let stream = session.streamResponse(generating: Horoscope.self,
                                                includeSchemaInPrompt: false) {
                """
                Generate a today horoscope based on zodiac sign, gender, and Github information for username: \(username).
                """
            }
            for try await partialResponse in stream {
                horoscope = partialResponse
            }
        } catch {
            self.error = error
        }
    }
}

@Generable
struct Horoscope: Equatable {

    @Guide(description: "Zodiac sign.")
    let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    let message: String
}

#Preview {
    ContentView()
        .colorScheme(.dark)
}
