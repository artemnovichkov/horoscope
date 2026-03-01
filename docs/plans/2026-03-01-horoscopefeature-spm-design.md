# HoroscopeFeature SPM Module Design

## Goal

Move `HoroscopeView` from the main app target into a new `HoroscopeFeature` SPM package, following the same pattern as `SettingsFeature`.

## New Package Structure

```
Packages/HoroscopeFeature/
├── Package.swift
└── Sources/
    └── HoroscopeFeature/
        └── HoroscopeView.swift
```

## Package.swift

- `swift-tools-version: 6.2`
- `platforms: [.iOS(.v26)]`
- Dependencies: `../HoroscopeClient`, ZodiacKit (same URL/version as HoroscopeClient)
- Single library target: `HoroscopeFeature`

## HoroscopeView Changes

- Make struct and init `public`
- Keep existing imports: `SwiftUI`, `ZodiacKit`, `FoundationModels`, `HoroscopeClient`

## Main App Changes

- Add `HoroscopeFeature` package dependency in Xcode project
- Add `import HoroscopeFeature` to `ContentView.swift`
- Delete `Horoscope/Views/HoroscopeView.swift`
