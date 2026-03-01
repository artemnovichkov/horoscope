# HoroscopeClient Package Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extract `HoroscopeService` and `UserInfoTool` from the app target into a new `Packages/HoroscopeClient` SPM package with `HoroscopeClient` (interface) and `HoroscopeClientLive` (implementation) targets.

**Architecture:** Follows the same `Client`/`ClientLive` split as `GithubClient` and `NotificationsClient`. `HoroscopeClient` exposes a public struct with closure-based API and owns the `Horoscope` model. `HoroscopeClientLive` holds the `HoroscopeService` and `UserInfoTool` logic and depends on `GithubClientLive` and `ZodiacKit`.

**Tech Stack:** SwiftUI, FoundationModels, HealthKit, ZodiacKit 3.1.0, GithubClientLive (local SPM), Swift 6.2, iOS 26+

---

### Task 1: Create package scaffold

**Files:**
- Create: `Packages/HoroscopeClient/Package.swift`
- Create: `Packages/HoroscopeClient/Sources/HoroscopeClient/.gitkeep`
- Create: `Packages/HoroscopeClient/Sources/HoroscopeClientLive/.gitkeep`
- Create: `Packages/HoroscopeClient/Tests/HoroscopeClientTests/.gitkeep`

**Step 1: Create directories**

```bash
mkdir -p Packages/HoroscopeClient/Sources/HoroscopeClient
mkdir -p Packages/HoroscopeClient/Sources/HoroscopeClientLive
mkdir -p Packages/HoroscopeClient/Tests/HoroscopeClientTests
```

**Step 2: Write Package.swift**

Create `Packages/HoroscopeClient/Package.swift`:

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HoroscopeClient",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "HoroscopeClient", targets: ["HoroscopeClient"]),
        .library(name: "HoroscopeClientLive", targets: ["HoroscopeClientLive"]),
    ],
    dependencies: [
        .package(path: "../GithubClient"),
        .package(url: "https://github.com/markbattistella/ZodiacKit", from: "3.1.0"),
    ],
    targets: [
        .target(name: "HoroscopeClient"),
        .target(
            name: "HoroscopeClientLive",
            dependencies: [
                "HoroscopeClient",
                .product(name: "GithubClientLive", package: "GithubClient"),
                .product(name: "ZodiacKit", package: "ZodiacKit"),
            ]
        ),
        .testTarget(
            name: "HoroscopeClientTests",
            dependencies: ["HoroscopeClient", "HoroscopeClientLive"]
        ),
    ]
)
```

**Step 3: Commit**

```bash
git add Packages/HoroscopeClient/
git commit -m "Add HoroscopeClient package scaffold"
```

---

### Task 2: Create HoroscopeClient interface

**Files:**
- Create: `Packages/HoroscopeClient/Sources/HoroscopeClient/HoroscopeClient.swift`

**Step 1: Write the interface**

Create `Packages/HoroscopeClient/Sources/HoroscopeClient/HoroscopeClient.swift`:

```swift
import FoundationModels

@Generable
public struct Horoscope: Equatable {
    @Guide(description: "Zodiac sign.")
    public let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    public let message: String
}

public struct HoroscopeClient: Sendable {
    public var generate: @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>
    public var horoscope: @Sendable (String) async throws -> Horoscope
    public var prewarm: @Sendable (String?) -> Void

    public init(
        generate: @escaping @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>,
        horoscope: @escaping @Sendable (String) async throws -> Horoscope,
        prewarm: @escaping @Sendable (String?) -> Void
    ) {
        self.generate = generate
        self.horoscope = horoscope
        self.prewarm = prewarm
    }
}
```

Note: `Horoscope` is moved here from `Horoscope/Horoscope.swift` and made `public`.

**Step 2: Commit**

```bash
git add Packages/HoroscopeClient/Sources/HoroscopeClient/
git commit -m "Add HoroscopeClient interface and Horoscope model"
```

---

### Task 3: Move UserInfoTool to HoroscopeClientLive

**Files:**
- Create: `Packages/HoroscopeClient/Sources/HoroscopeClientLive/UserInfoTool.swift`

**Step 1: Create UserInfoTool in the package**

Create `Packages/HoroscopeClient/Sources/HoroscopeClientLive/UserInfoTool.swift`.
This is a copy of `Horoscope/Tools/UserInfoTool.swift` with `import ZodiacKit` added (ZodiacKit is now a package dep) and access level unchanged (internal):

```swift
import FoundationModels
import HealthKit
import ZodiacKit

@MainActor
final class UserInfoTool: Tool {
    enum Error: Swift.Error, LocalizedError {
        case healthDataNotAvailable

        var errorDescription: String? {
            switch self {
            case .healthDataNotAvailable:
                "Health data is not available on this device"
            }
        }
    }

    let name = "fetchUserInfo"
    let description = "Get zodiac sign and gender for user"

    @Generable
    struct Arguments {}

    private let healthStore = HKHealthStore()
    private let zodiacService = ZodiacService()

    private let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
    private let biologicalSexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!

    func call(arguments: Arguments) async throws -> GeneratedContent {
        #if os(iOS)
        guard HKHealthStore.isHealthDataAvailable() else {
            throw Error.healthDataNotAvailable
        }
        try await healthStore.requestAuthorization(toShare: [], read: [dateOfBirthType, biologicalSexType])
        return try GeneratedContent(properties: [
            "sign": zodiacSign(),
            "gender": gender(),
        ])
        #else
        return GeneratedContent(properties: [:])
        #endif
    }

    private func zodiacSign() throws -> String? {
        let dateOfBirthComponents = try healthStore.dateOfBirthComponents()
        guard let birthDate = Calendar.current.date(from: dateOfBirthComponents) else {
            return nil
        }
        return try zodiacService.getWesternZodiac(from: birthDate).name.lowercased()
    }

    private func gender() throws -> String {
        switch try healthStore.biologicalSex().biologicalSex {
        case .notSet: "Not Set"
        case .female: "Female"
        case .male: "Male"
        case .other: "Other"
        @unknown default: "Unknown"
        }
    }
}
```

**Step 2: Commit**

```bash
git add Packages/HoroscopeClient/Sources/HoroscopeClientLive/UserInfoTool.swift
git commit -m "Move UserInfoTool to HoroscopeClientLive"
```

---

### Task 4: Move HoroscopeService to HoroscopeClientLive and create live extension

**Files:**
- Create: `Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeService.swift`
- Create: `Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeClientLive.swift`

**Step 1: Create HoroscopeService in the package**

Create `Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeService.swift`.
This is the internal service, moved from `Horoscope/Services/HoroscopeService.swift`. Import `HoroscopeClient` for the `Horoscope` type and `GithubClientLive` for `GithubInfoTool`:

```swift
import FoundationModels
import GithubClientLive
import HoroscopeClient

@MainActor
final class HoroscopeService {
    private(set) lazy var session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
        """
        Your job is to create a horoscope for developers.

        For each request from the user:
        - get the zodiac sign and the gender using the fetchUserInfo tool.
        - get Github data using the fetchGithubInfo tool.
        """
    }

    func prewarm(username: String?) {
        var promptPrefix: Prompt?
        if let username {
            promptPrefix = prompt(username: username)
        }
        session.prewarm(promptPrefix: promptPrefix)
    }

    func horoscope(username: String) async throws -> Horoscope {
        try await session.respond(generating: Horoscope.self) {
            prompt(username: username)
        }.content
    }

    func horoscopeStream(username: String) -> LanguageModelSession.ResponseStream<Horoscope> {
        session.streamResponse(generating: Horoscope.self) {
            prompt(username: username)
        }
    }

    @PromptBuilder
    private func prompt(username: String) -> Prompt {
        "Generate a funny, witty today horoscope combining zodiac sign, gender and coding activity for username: \(username)."
    }
}
```

**Step 2: Create live extension**

Create `Packages/HoroscopeClient/Sources/HoroscopeClientLive/HoroscopeClientLive.swift`:

```swift
import HoroscopeClient

@MainActor
public extension HoroscopeClient {
    static let live: HoroscopeClient = {
        let service = HoroscopeService()
        return HoroscopeClient(
            generate: { username in
                service.horoscopeStream(username: username)
            },
            horoscope: { username in
                try await service.horoscope(username: username)
            },
            prewarm: { username in
                service.prewarm(username: username)
            }
        )
    }()
}
```

**Step 3: Create test stub**

Create `Packages/HoroscopeClient/Tests/HoroscopeClientTests/HoroscopeClientTests.swift`:

```swift
import Testing
import HoroscopeClient
import HoroscopeClientLive

struct HoroscopeClientTests {
}
```

**Step 4: Commit**

```bash
git add Packages/HoroscopeClient/Sources/HoroscopeClientLive/ Packages/HoroscopeClient/Tests/
git commit -m "Add HoroscopeService and live extension in HoroscopeClientLive"
```

---

### Task 5: Add HoroscopeClient package to Xcode project

This must be done in Xcode — the `.pbxproj` format is complex to edit manually.

**Step 1: Open Xcode**

Open `Horoscope.xcodeproj` in Xcode.

**Step 2: Add local package**

- Select the project in the navigator → select the `Horoscope` project (not target) → `Package Dependencies` tab
- Click `+` → `Add Local...`
- Navigate to `Packages/HoroscopeClient` and click `Add Package`

**Step 3: Add library products to app target**

When prompted, add both `HoroscopeClient` and `HoroscopeClientLive` to the `Horoscope` app target.

**Step 4: Verify**

Build the project (Cmd+B). The package should compile. Errors about missing `Horoscope` type or `HoroscopeService` in the app are expected — fix in next tasks.

---

### Task 6: Update HoroscopeApp.swift

**Files:**
- Modify: `Horoscope/HoroscopeApp.swift`

**Step 1: Replace `HoroscopeService` with `HoroscopeClient.live`**

Add `import HoroscopeClientLive` at the top. Replace `HoroscopeService()` with `HoroscopeClient.live`:

Before (line 18-19):
```swift
let horoscopeService = HoroscopeService()
AppDependencyManager.shared.add(dependency: horoscopeService)
```

After:
```swift
let horoscopeClient = HoroscopeClient.live
AppDependencyManager.shared.add(dependency: horoscopeClient)
```

Also add `import HoroscopeClient` (for the type).

**Step 2: Commit**

```bash
git add Horoscope/HoroscopeApp.swift
git commit -m "Register HoroscopeClient.live with AppDependencyManager"
```

---

### Task 7: Update HoroscopeIntent.swift

**Files:**
- Modify: `Horoscope/Shortcuts/HoroscopeIntent.swift`

**Step 1: Replace `HoroscopeService` dependency with `HoroscopeClient`**

Add `import HoroscopeClient`. Replace `@Dependency private var horoscopeService: HoroscopeService` with `@Dependency private var horoscopeClient: HoroscopeClient`. Update the call in `perform()`:

Before:
```swift
import FoundationModels

@Dependency
private var horoscopeService: HoroscopeService

func perform() async throws -> some IntentResult & ShowsSnippetView {
    let username = UserDefaults.standard.string(forKey: "username") ?? ""
    if username.isEmpty {
        throw HoroscopeIntentError.missingUsername
    }
    let horoscope = try await horoscopeService.horoscope(username: username)
    return .result(view: HoroscopeView(horoscope: horoscope.asPartiallyGenerated()))
}
```

After:
```swift
import HoroscopeClient

@Dependency
private var horoscopeClient: HoroscopeClient

func perform() async throws -> some IntentResult & ShowsSnippetView {
    let username = UserDefaults.standard.string(forKey: "username") ?? ""
    if username.isEmpty {
        throw HoroscopeIntentError.missingUsername
    }
    let horoscope = try await horoscopeClient.horoscope(username)
    return .result(view: HoroscopeView(horoscope: horoscope.asPartiallyGenerated()))
}
```

Remove `import FoundationModels` if no longer needed in this file.

**Step 2: Commit**

```bash
git add Horoscope/Shortcuts/HoroscopeIntent.swift
git commit -m "Update HoroscopeIntent to use HoroscopeClient"
```

---

### Task 8: Update ContentViewModel.swift

**Files:**
- Modify: `Horoscope/Views/Content/ContentViewModel.swift`

**Step 1: Replace HoroscopeService with HoroscopeClient**

Add `import HoroscopeClient`. Replace service property and all usages:

Before:
```swift
@ObservationIgnored
private(set) var service: HoroscopeService = HoroscopeService()
```

After:
```swift
@ObservationIgnored
private(set) var client: HoroscopeClient = .live
```

Update `onAppear` (line 29):
```swift
// Before
service.prewarm(username: username)
// After
client.prewarm(username)
```

Update `generate` (line 44):
```swift
// Before
for try await partialResponse in service.horoscopeStream(username: username) {
// After
for try await partialResponse in client.generate(username) {
```

Remove `import FoundationModels` if unused.
Add `import HoroscopeClientLive` (for `.live` static property).

**Step 2: Commit**

```bash
git add Horoscope/Views/Content/ContentViewModel.swift
git commit -m "Update ContentViewModel to use HoroscopeClient"
```

---

### Task 9: Delete old files from app target

**Files:**
- Delete: `Horoscope/Horoscope.swift`
- Delete: `Horoscope/Services/HoroscopeService.swift`
- Delete: `Horoscope/Tools/UserInfoTool.swift`

**Step 1: Delete files via Xcode**

In Xcode's file navigator, delete `Horoscope.swift`, `HoroscopeService.swift`, and `UserInfoTool.swift`. Choose "Move to Trash" when prompted. This removes them from both disk and the Xcode target.

**Step 2: Verify build**

Build (Cmd+B). Fix any remaining "use of undeclared type 'Horoscope'" errors by adding `import HoroscopeClient` to affected files (e.g. `HoroscopeView.swift`, `ContentView.swift`).

**Step 3: Commit**

```bash
git add -A
git commit -m "Remove HoroscopeService, UserInfoTool, Horoscope from app target"
```

---

### Task 10: Final build verification

**Step 1: Clean build**

In Xcode: Product → Clean Build Folder (Shift+Cmd+K), then Build (Cmd+B).

Expected: zero errors, zero warnings related to this change.

**Step 2: Commit**

```bash
git add -A
git commit -m "Add HoroscopeClient smp package"
```
