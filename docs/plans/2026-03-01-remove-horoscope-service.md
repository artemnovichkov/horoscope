# Remove HoroscopeService Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Inline `HoroscopeService` logic directly into `HoroscopeClient.live`, eliminating the unnecessary class abstraction.

**Architecture:** Move `session`, `prewarm`, `horoscope`, `horoscopeStream`, and `prompt` from `HoroscopeService` into the `HoroscopeClient.live` static closure in `HoroscopeClientLive.swift`. Delete `HoroscopeService.swift`.

**Tech Stack:** Swift, FoundationModels, GithubClientLive

---

### Task 1: Inline HoroscopeService into HoroscopeClientLive

**Files:**
- Modify: `Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeClientLive.swift`
- Delete: `Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeService.swift`

**Step 1: Rewrite HoroscopeClientLive.swift**

Replace the contents of `HoroscopeClientLive.swift` with:

```swift
import FoundationModels
import GithubClientLive
import HoroscopeClient

@MainActor
public extension HoroscopeClient {
    static let live: HoroscopeClient = {
        let session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
            """
            Your job is to create a horoscope for developers.

            For each request from the user:
            - get the zodiac sign and the gender using the fetchUserInfo tool.
            - get Github data using the fetchGithubInfo tool.
            """
        }

        @PromptBuilder
        func prompt(username: String) -> Prompt {
            "Generate a funny, witty today horoscope combining zodiac sign, gender and coding activity for username: \(username)."
        }

        return HoroscopeClient(
            generate: { username in
                session.streamResponse(generating: Horoscope.self) {
                    prompt(username: username)
                }
            },
            horoscope: { username in
                try await session.respond(generating: Horoscope.self) {
                    prompt(username: username)
                }.content
            },
            prewarm: { username in
                var promptPrefix: Prompt?
                if let username {
                    promptPrefix = prompt(username: username)
                }
                session.prewarm(promptPrefix: promptPrefix)
            },
            session: {
                session
            }
        )
    }()
}
```

**Step 2: Delete HoroscopeService.swift**

```bash
rm Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeService.swift
```

**Step 3: Build to verify**

Open in Xcode and build the `HoroscopeClient` package (or full app). Expected: no errors.

**Step 4: Commit**

```bash
git add Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeClientLive.swift
git rm Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeService.swift
git commit -m "Remove HoroscopeService, inline logic into HoroscopeClient.live"
```
