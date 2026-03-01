# MainFeature Module Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extract `ContentView`, `ContentViewModel`, and `Tips` into a new `MainFeature` SPM package, matching the established `*Feature` module pattern.

**Architecture:** Create `Packages/MainFeature/` with a single library target containing the moved source files plus a new `LocalizedStringResource+MainFeature.swift`. The main app target drops the moved files, imports `MainFeature`, and loses the migrated xcstrings keys.

**Tech Stack:** Swift 6.2, SwiftUI, SPM, TipKit, FoundationModels, AppIntents

---

### Task 1: Create MainFeature package scaffold

**Files:**
- Create: `Packages/MainFeature/Package.swift`
- Create dir: `Packages/MainFeature/Sources/MainFeature/`
- Create dir: `Packages/MainFeature/Sources/MainFeature/Resources/`

**Step 1: Write Package.swift**

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MainFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "MainFeature",
            targets: ["MainFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../HoroscopeClient"),
        .package(path: "../HoroscopeFeature"),
        .package(path: "../SettingsFeature"),
        .package(path: "../NotificationsClient"),
        .package(url: "https://github.com/artemnovichkov/TranscriptDebugMenu", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MainFeature",
            dependencies: [
                "HoroscopeClient",
                .product(name: "HoroscopeClientLive", package: "HoroscopeClient"),
                "HoroscopeFeature",
                "SettingsFeature",
                .product(name: "NotificationsClientLive", package: "NotificationsClient"),
                "TranscriptDebugMenu",
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
```

**Step 2: Create directories**

```bash
mkdir -p /Users/artemnovichkov/Developer/horoscope/Packages/MainFeature/Sources/MainFeature/Resources
```

**Step 3: Verify structure**

```bash
ls Packages/MainFeature/Sources/MainFeature/
```
Expected: `Resources/` directory exists.

---

### Task 2: Create LocalizedStringResource+MainFeature.swift

**Files:**
- Create: `Packages/MainFeature/Sources/MainFeature/LocalizedStringResource+MainFeature.swift`

**Step 1: Write the file**

```swift
import Foundation

extension LocalizedStringResource {
    static var horoscope: LocalizedStringResource {
        LocalizedStringResource("Horoscope", bundle: .module)
    }
    static var forDevelopers: LocalizedStringResource {
        LocalizedStringResource("forDevelopers", bundle: .module)
    }
    static var transcript: LocalizedStringResource {
        LocalizedStringResource("Transcript", bundle: .module)
    }
    static var generatingHoroscope: LocalizedStringResource {
        LocalizedStringResource("Generating Horoscope...", bundle: .module)
    }
    static var githubUsername: LocalizedStringResource {
        LocalizedStringResource("Github username", bundle: .module)
    }
    static var generate: LocalizedStringResource {
        LocalizedStringResource("Generate", bundle: .module)
    }
    static var appleIntelligenceNotEnabled: LocalizedStringResource {
        LocalizedStringResource("appleIntelligenceNotEnabled", bundle: .module)
    }
    static var deviceNotEligible: LocalizedStringResource {
        LocalizedStringResource("deviceNotEligible", bundle: .module)
    }
    static var modelNotReady: LocalizedStringResource {
        LocalizedStringResource("modelNotReady", bundle: .module)
    }
    static var unknownReason: LocalizedStringResource {
        LocalizedStringResource("unknownReason", bundle: .module)
    }
    static var shareTipMessage: LocalizedStringResource {
        LocalizedStringResource("shareTipMessage", bundle: .module)
    }
    static var sharingTipTitle: LocalizedStringResource {
        LocalizedStringResource("sharingTipTitle", bundle: .module)
    }
    static var usernameTipMessage: LocalizedStringResource {
        LocalizedStringResource("usernameTipMessage", bundle: .module)
    }
    static var usernameTipTitle: LocalizedStringResource {
        LocalizedStringResource("usernameTipTitle", bundle: .module)
    }
}
```

> Note: `settings` is already defined in `SettingsFeature`'s extension — do NOT redefine it here.

---

### Task 3: Create Resources/Localizable.xcstrings

**Files:**
- Create: `Packages/MainFeature/Sources/MainFeature/Resources/Localizable.xcstrings`

**Step 1: Write the xcstrings file**

Copy the following keys from `Horoscope/Localizable.xcstrings` into a new xcstrings file:

```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "appleIntelligenceNotEnabled" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Apple Intelligence is not enabled. Please enable it in Settings."
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Apple Intelligence недоступна. Пожалуйста, включите её в Настройках."
          }
        }
      }
    },
    "deviceNotEligible" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "This device is not eligible for Apple Intelligence. Please use a compatible device."
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Устройство несовместимо с Apple Intelligence. Воспользуйтесь устройством, которое это подерживает"
          }
        }
      }
    },
    "forDevelopers" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "for developers"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "для разработчиков"
          }
        }
      }
    },
    "Generate" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Generate"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Сгенерировать"
          }
        }
      }
    },
    "Generating Horoscope..." : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Generating horoscope…"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Генерируем гороскоп…"
          }
        }
      }
    },
    "Github username" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Github username"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Имя пользователя Github"
          }
        }
      }
    },
    "Horoscope" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Horoscope"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Гороскоп"
          }
        }
      }
    },
    "modelNotReady" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "The language model is not ready yet. Please try again later."
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Языковая модель недоступна. попробуйте позже."
          }
        }
      }
    },
    "shareTipMessage" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Share your horoscope with your friends"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Поделитесь гороскопом со своими друзьями"
          }
        }
      }
    },
    "sharingTipTitle" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Sharing"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Поделиться"
          }
        }
      }
    },
    "Transcript" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Transcript"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Транскрипт"
          }
        }
      }
    },
    "unknownReason" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "The language model is unavailable for an unknown reason."
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Языковая модель недоступна."
          }
        }
      }
    },
    "usernameTipMessage" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Enter your Github username and tap Generate"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Введите имя пользователя Github и нажмите Сгенерировать"
          }
        }
      }
    },
    "usernameTipTitle" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Username"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Имя пользователя"
          }
        }
      }
    }
  },
  "version" : "1.1"
}
```

---

### Task 4: Move source files into MainFeature

**Files:**
- Move: `Horoscope/Views/Content/ContentView.swift` → `Packages/MainFeature/Sources/MainFeature/ContentView.swift`
- Move: `Horoscope/Views/Content/ContentViewModel.swift` → `Packages/MainFeature/Sources/MainFeature/ContentViewModel.swift`
- Move: `Horoscope/Tips.swift` → `Packages/MainFeature/Sources/MainFeature/Tips.swift`

**Step 1: Copy files**

```bash
cp Horoscope/Views/Content/ContentView.swift Packages/MainFeature/Sources/MainFeature/ContentView.swift
cp Horoscope/Views/Content/ContentViewModel.swift Packages/MainFeature/Sources/MainFeature/ContentViewModel.swift
cp Horoscope/Tips.swift Packages/MainFeature/Sources/MainFeature/Tips.swift
```

**Step 2: Add `public` visibility to ContentView**

In `Packages/MainFeature/Sources/MainFeature/ContentView.swift`, change:
```swift
struct ContentView: View {
```
to:
```swift
public struct ContentView: View {
```

And add a public initializer after the state declarations:
```swift
public init() {}
```

**Step 3: Add `public` visibility to ContentViewModel**

In `Packages/MainFeature/Sources/MainFeature/ContentViewModel.swift`, change:
```swift
@Observable
final class ContentViewModel {
```
to:
```swift
@Observable
final class ContentViewModel {
```
No change needed — `ContentViewModel` is internal to the module and only used by `ContentView` which is in the same module.

**Step 4: Verify Tips.swift needs no visibility changes**

`ShareTip` and `UsernameTip` are used only within `ContentView` (same module), so no `public` modifier needed.

---

### Task 5: Add MainFeature to Xcode project

This step must be done in Xcode:

1. Open `Horoscope.xcodeproj` in Xcode
2. Select the project in the navigator → select the `Horoscope` target
3. Go to **General** → **Frameworks, Libraries, and Embedded Content**
4. Click **+** → **Add Other...** → **Add Package Dependency...**
5. Click **Add Local...** and select `Packages/MainFeature`
6. Add the `MainFeature` library to the **Horoscope** target

**Verify:** The package appears under `Packages/MainFeature` in the Xcode project navigator.

---

### Task 6: Update HoroscopeApp.swift

**Files:**
- Modify: `Horoscope/HoroscopeApp.swift`

**Step 1: Add import**

Add `import MainFeature` to the imports in `HoroscopeApp.swift`.

Also remove `import HoroscopeClient` and `import HoroscopeClientLive` from `HoroscopeApp.swift` if they're no longer directly used there (they're now pulled in transitively via `MainFeature`). Keep them if `HoroscopeApp.swift` references types from those modules directly.

---

### Task 7: Remove moved files from the main Horoscope target

**Step 1: Delete originals from the Xcode target**

In Xcode, select and delete (Move to Trash) from the **Horoscope** target:
- `Horoscope/Views/Content/ContentView.swift`
- `Horoscope/Views/Content/ContentViewModel.swift`
- `Horoscope/Tips.swift`

Or delete via CLI and remove references from Xcode:
```bash
rm Horoscope/Views/Content/ContentView.swift
rm Horoscope/Views/Content/ContentViewModel.swift
rm Horoscope/Tips.swift
```

Then in Xcode, delete the red (missing) file references from the project navigator.

---

### Task 8: Remove migrated strings from main Localizable.xcstrings

**Files:**
- Modify: `Horoscope/Localizable.xcstrings`

**Step 1: Remove these keys** from `Horoscope/Localizable.xcstrings`:

- `appleIntelligenceNotEnabled`
- `deviceNotEligible`
- `forDevelopers`
- `Generate`
- `Generating Horoscope...`
- `Github username`
- `Horoscope`
- `modelNotReady`
- `shareTipMessage`
- `sharingTipTitle`
- `Transcript`
- `unknownReason`
- `usernameTipMessage`
- `usernameTipTitle`

Keep all other keys that belong to other targets/modules.

---

### Task 9: Build and verify

**Step 1: Build in Xcode**

Select the **Horoscope** scheme and build (`Cmd+B`).

Expected: No errors. `ContentView` from `MainFeature` is used as the root view.

**Step 2: Fix any issues**

Common issues:
- Missing `public` on `ContentView` or its `init()` — add them
- String resolution failures — verify xcstrings keys match exactly what's in `LocalizedStringResource+MainFeature.swift`
- `settings` ambiguity — if both `MainFeature` and `SettingsFeature` define `.settings`, remove it from `MainFeature` (it's already in `SettingsFeature`)

**Step 3: Commit**

```bash
git add Packages/MainFeature/
git add Horoscope/HoroscopeApp.swift
git add Horoscope/Localizable.xcstrings
git add Horoscope.xcodeproj/
git commit -m "Add MainFeature module, move ContentView/ViewModel/Tips"
```
