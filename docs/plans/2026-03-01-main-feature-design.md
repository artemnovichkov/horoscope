# MainFeature Module Design

**Goal:** Extract `ContentView` and related code into a new `MainFeature` SPM package, following the established `*Feature` module pattern.

---

## Module Structure

```
Packages/MainFeature/
├── Package.swift
└── Sources/MainFeature/
    ├── ContentView.swift          (moved)
    ├── ContentViewModel.swift     (moved)
    ├── Tips.swift                 (moved from Horoscope/)
    ├── LocalizedStringResource+MainFeature.swift  (new)
    └── Resources/
        └── Localizable.xcstrings  (new, subset for MainFeature strings)
```

## Package.swift

- `platforms`: `.iOS(.v26)` (matching existing Feature packages)
- Dependencies:
  - `../HoroscopeClient` → `HoroscopeClient`, `HoroscopeClientLive`
  - `../HoroscopeFeature` → `HoroscopeFeature`
  - `../SettingsFeature` → `SettingsFeature`
  - `../NotificationsClient` → `NotificationsClientLive`

> Note: `TranscriptDebugMenu` is also imported in `ContentView`. It must be added as a package dependency in `MainFeature` (same source as the Xcode project uses).

## String Keys Moving to MainFeature

From the main target's `Localizable.xcstrings`, these keys belong to MainFeature:

- `horoscope`, `forDevelopers`
- `transcript`, `settings`, `generate`, `githubUsername`
- `generatingHoroscope`
- `appleIntelligenceNotEnabled`, `deviceNotEligible`, `modelNotReady`, `unknownReason`
- `shareTipMessage`, `sharingTipTitle`, `usernameTipMessage`, `usernameTipTitle`

Remaining in main target: strings owned by Shortcuts/AppDelegate/SettingsFeature/HoroscopeFeature.

## Main App Target Changes

- Remove `ContentView.swift`, `ContentViewModel.swift`, `Tips.swift` from the Horoscope target
- Add `MainFeature` as a dependency in the Xcode project
- `HoroscopeApp.swift`: add `import MainFeature`
- Delete moved strings from `Horoscope/Localizable.xcstrings`

## Open Questions

1. Where is `TranscriptDebugMenu` defined — external URL or local package?
2. Should macOS/visionOS platform support be added now or deferred?
