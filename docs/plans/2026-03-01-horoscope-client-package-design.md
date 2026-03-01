# HoroscopeClient SPM Package Design

## Goal

Extract `HoroscopeService` and `UserInfoTool` from the main app into a new `HoroscopeClient` SPM package following the same `Client`/`ClientLive` split as `GithubClient` and `NotificationsClient`.

## Package Structure

```
Packages/HoroscopeClient/
  Package.swift
  Sources/
    HoroscopeClient/
      HoroscopeClient.swift     # public interface struct + Horoscope model
    HoroscopeClientLive/
      HoroscopeClientLive.swift  # .live static extension
      HoroscopeService.swift     # internal, moved from app
      UserInfoTool.swift         # internal, moved from app
  Tests/
    HoroscopeClientTests/
      HoroscopeClientTests.swift
```

## Interface (`HoroscopeClient` target)

```swift
public struct HoroscopeClient: Sendable {
    public var generate: @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>
}
```

`Horoscope` model moves here, becomes `public`.

## Implementation (`HoroscopeClientLive` target)

- Depends on `HoroscopeClient` + `GithubClientLive`
- Brings in HealthKit and ZodiacKit
- `UserInfoTool` and `HoroscopeService` are `internal`
- Exposes `.live` static instance on `HoroscopeClient`

## App Changes

- Remove `HoroscopeService.swift` and `UserInfoTool.swift` from app target
- `ContentViewModel` uses `HoroscopeClient` instead of `HoroscopeService` directly
- Add `HoroscopeClientLive` dependency to app target
- `Horoscope` type is now imported from `HoroscopeClient`

## Dependencies

```
HoroscopeClient  (FoundationModels)
HoroscopeClientLive  (HoroscopeClient, GithubClientLive, HealthKit, ZodiacKit)
```
