# HoroscopeFeature SPM Module Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move `HoroscopeView` from the main app target into a new `HoroscopeFeature` SPM package.

**Architecture:** Create `Packages/HoroscopeFeature/` mirroring the `SettingsFeature` pattern: single library target, `public` view, `LocalizedStringResource` extension with `bundle: .module`, `Resources/Localizable.xcstrings`. Wire the package into `project.pbxproj` by editing four sections, then update `ContentView.swift` and delete the original file.

**Tech Stack:** Swift 6.2, SwiftUI, SPM, Xcode pbxproj editing

---

### Task 1: Create the package directory and Package.swift

**Files:**
- Create: `Packages/HoroscopeFeature/Package.swift`

**Step 1: Create directory**
```bash
mkdir -p Packages/HoroscopeFeature/Sources/HoroscopeFeature/Resources
```

**Step 2: Write Package.swift**
```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HoroscopeFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "HoroscopeFeature",
            targets: ["HoroscopeFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../HoroscopeClient"),
        .package(url: "https://github.com/markbattistella/ZodiacKit", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "HoroscopeFeature",
            dependencies: [
                "HoroscopeClient",
                .product(name: "ZodiacKit", package: "ZodiacKit"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
```

**Step 3: Commit**
```bash
git add Packages/HoroscopeFeature/Package.swift
git commit -m "Add HoroscopeFeature package"
```

---

### Task 2: Create HoroscopeView.swift in the new package

**Files:**
- Create: `Packages/HoroscopeFeature/Sources/HoroscopeFeature/HoroscopeView.swift`

**Step 1: Write the file**

Content is the original `Horoscope/Views/HoroscopeView.swift` with `public` added to the struct:

```swift
//
//  Created by Artem Novichkov on 28.07.2025.
//

import SwiftUI
import ZodiacKit
import FoundationModels
import HoroscopeClient

/// A SwiftUI view that displays a partially generated horoscope.
///
/// This view conditionally renders a user's zodiac sign and horoscope message.
public struct HoroscopeView: View {
    public var horoscope: Horoscope.PartiallyGenerated?

    public init(horoscope: Horoscope.PartiallyGenerated? = nil) {
        self.horoscope = horoscope
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let sign = horoscope?.sign, let zodiacSign = Western(rawValue: sign.lowercased()) {
                Text(.yourHoroscopeSign)
                    .font(.headline)
                Text(zodiacSign.emoji + " " + zodiacSign.name)
                    .font(.largeTitle.bold())
                    .transition(.opacity)
            }
            if let message = horoscope?.message {
                Text(message)
                    .font(.body)
                    .transition(.opacity)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let jsons = [
        #"{"sign": "aries"#,
        #"{"sign": "aries", "message": "message"#
    ]
    VStack {
        ForEach(jsons, id: \.self) { json in
            let content = try! GeneratedContent(json: json)
            HoroscopeView(horoscope: try! .init(content))
        }
    }
}
```

**Step 2: Commit**
```bash
git add Packages/HoroscopeFeature/Sources/HoroscopeFeature/HoroscopeView.swift
git commit -m "Add HoroscopeView to HoroscopeFeature"
```

---

### Task 3: Create LocalizedStringResource extension and Localizable.xcstrings

**Files:**
- Create: `Packages/HoroscopeFeature/Sources/HoroscopeFeature/LocalizedStringResource+HoroscopeFeature.swift`
- Create: `Packages/HoroscopeFeature/Sources/HoroscopeFeature/Resources/Localizable.xcstrings`

**Step 1: Write the extension**
```swift
import Foundation

extension LocalizedStringResource {
    static var yourHoroscopeSign: LocalizedStringResource {
        LocalizedStringResource("Your Horoscope Sign:", bundle: .module)
    }
}
```

**Step 2: Write Localizable.xcstrings**
```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "Your Horoscope Sign:" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Your Horoscope Sign:"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Ваш знак зодиака:"
          }
        }
      }
    }
  },
  "version" : "1.1"
}
```

**Step 3: Commit**
```bash
git add Packages/HoroscopeFeature/Sources/HoroscopeFeature/LocalizedStringResource+HoroscopeFeature.swift
git add Packages/HoroscopeFeature/Sources/HoroscopeFeature/Resources/Localizable.xcstrings
git commit -m "Add localization to HoroscopeFeature"
```

---

### Task 4: Wire HoroscopeFeature into project.pbxproj

**Files:**
- Modify: `Horoscope.xcodeproj/project.pbxproj`

Use these three UUIDs (chosen to follow existing naming convention):
- `06HF00012E34BB520093A809` — `XCLocalSwiftPackageReference`
- `06HF00022E34BB520093A809` — `XCSwiftPackageProductDependency`
- `06HF00032E34BB520093A809` — `PBXBuildFile`

**Step 1: Add PBXBuildFile entry**

After line 22 (`06SF00012E34BB520093A809 /* SettingsFeature in Frameworks */`):
```
		06HF00032E34BB520093A809 /* HoroscopeFeature in Frameworks */ = {isa = PBXBuildFile; productRef = 06HF00022E34BB520093A809 /* HoroscopeFeature */; };
```

**Step 2: Add to PBXFrameworksBuildPhase (Horoscope target, ID 060919322E34BA780093A809)**

After `06SF00012E34BB520093A809 /* SettingsFeature in Frameworks */,`:
```
				06HF00032E34BB520093A809 /* HoroscopeFeature in Frameworks */,
```

**Step 3: Add to PBXNativeTarget packageProductDependencies (Horoscope target)**

After `06SF00022E34BB520093A809 /* SettingsFeature */,`:
```
				06HF00022E34BB520093A809 /* HoroscopeFeature */,
```

**Step 4: Add to PBXProject packageReferences**

After `06SF00032E34BB520093A809 /* XCLocalSwiftPackageReference "Packages/SettingsFeature" */,`:
```
				06HF00012E34BB520093A809 /* XCLocalSwiftPackageReference "Packages/HoroscopeFeature" */,
```

**Step 5: Add XCLocalSwiftPackageReference entry**

After `06SF00032E34BB520093A809` entry in `XCLocalSwiftPackageReference` section:
```
		06HF00012E34BB520093A809 /* XCLocalSwiftPackageReference "Packages/HoroscopeFeature" */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = Packages/HoroscopeFeature;
		};
```

**Step 6: Add XCSwiftPackageProductDependency entry**

After `06HC00032E34BB520093A809 /* HoroscopeClientLive */` entry in `XCSwiftPackageProductDependency` section:
```
		06HF00022E34BB520093A809 /* HoroscopeFeature */ = {
			isa = XCSwiftPackageProductDependency;
			package = 06HF00012E34BB520093A809 /* XCLocalSwiftPackageReference "Packages/HoroscopeFeature" */;
			productName = HoroscopeFeature;
		};
```

**Step 7: Commit**
```bash
git add Horoscope.xcodeproj/project.pbxproj
git commit -m "Add HoroscopeFeature package to Xcode project"
```

---

### Task 5: Update ContentView.swift and delete original HoroscopeView.swift

**Files:**
- Modify: `Horoscope/Views/Content/ContentView.swift`
- Delete: `Horoscope/Views/HoroscopeView.swift`

**Step 1: Add import to ContentView.swift**

After `import SettingsFeature`:
```swift
import HoroscopeFeature
```

**Step 2: Delete original file**
```bash
rm Horoscope/Views/HoroscopeView.swift
```

**Step 3: Commit**
```bash
git add Horoscope/Views/Content/ContentView.swift
git rm Horoscope/Views/HoroscopeView.swift
git commit -m "Move HoroscopeView to HoroscopeFeature module"
```

---

### Task 6: Remove "Your Horoscope Sign:" from main app Localizable.xcstrings

**Files:**
- Modify: `Horoscope/Localizable.xcstrings`

**Step 1: Remove the key**

Delete the entire `"Your Horoscope Sign:"` entry from `Horoscope/Localizable.xcstrings`.

**Step 2: Commit**
```bash
git add Horoscope/Localizable.xcstrings
git commit -m "Remove yourHoroscopeSign from main app strings"
```

---

### Task 7: Build and verify

**Step 1: Open Xcode and build the Horoscope scheme**

Expected: Build succeeds with no errors.

If Xcode reports "cannot find type 'HoroscopeView'" — verify `import HoroscopeFeature` is in ContentView.swift.

If Xcode reports package resolution error — verify `relativePath = Packages/HoroscopeFeature` in pbxproj and that `Packages/HoroscopeFeature/Package.swift` exists.

If Xcode reports "cannot find 'yourHoroscopeSign'" — verify `LocalizedStringResource+HoroscopeFeature.swift` is in the package sources.
