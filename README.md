# Flutter Flavor Setup (Android & iOS) — Step-by-step Guide

This guide combines both Android and iOS flavor implementation into one clear, step-by-step document. It is written in **README.md style** so you can directly add it to your GitHub repository.

---

## Table of Contents

1. Overview
2. Prerequisites
3. Project Structure (recommended)
4. Android Setup (step-by-step)
5. iOS Setup (step-by-step)
6. Flutter/Dart Flavor Config
7. Build & Run Commands
8. Firebase Setup (Android & iOS)
9. Testing & Verification Checklist
10. Common Issues & Troubleshooting
11. Quick Reference Commands

---

# 1. Overview

**Flavors** allow you to create multiple build variants (dev, qa, prod) from a single codebase, each with its own app name, bundle/package ID, signing, resources, and API endpoints.

**Benefits**:

* Side-by-side install of dev, qa, and prod apps.
* Different endpoints or feature flags per environment.
* Maintain a single codebase with environment-specific builds.

---

# 2. Prerequisites

* Flutter (stable channel)
* Android Studio with Gradle support
* Xcode (for iOS builds)
* Firebase console access (if app uses Firebase)
* Basic understanding of Xcode build configurations and schemes

---

# 3. Project Structure (Recommended)

```
lib/
├── flavor_config.dart
├── common_main.dart
├── main_dev.dart
├── main_qa.dart
└── main_prod.dart

android/app/
└── build.gradle.kts

ios/
├── Runner.xcworkspace
├── Runner/Info.plist
└── tool/
    ├── setup_ios_flavors.sh
    └── update_info_plist.sh
```

---

# 4. Android Setup

## 4.1: Define Product Flavors (`android/app/build.gradle.kts`)

```kotlin
flavorDimensions += "default"
productFlavors {
    create("dev") {
        dimension = "default"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "GameElevate Dev")
        signingConfig = signingConfigs.getByName("debug")
    }
    create("qa") {
        dimension = "default"
        applicationIdSuffix = ".qa"
        versionNameSuffix = "-qa"
        resValue("string", "app_name", "GameElevate QA")
        signingConfig = signingConfigs.getByName("debug")
    }
    create("prod") {
        dimension = "default"
        resValue("string", "app_name", "GameElevate")
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## 4.2: Update `AndroidManifest.xml`

```xml
<application
    android:label="@string/app_name"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

## 4.3: Firebase for Android

* Add package IDs (`com.app.dev`, `com.app.qa`, `com.app`) in Firebase.
* Either use one `google-services.json` with multiple clients OR separate files.
* Place file(s) in `android/app/`.

---

# 5. iOS Setup

## 5.1: Update `Info.plist`

Replace app name with variable:

```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
<key>CFBundleName</key>
<string>$(APP_DISPLAY_NAME)</string>
```

## 5.2: Add Configurations in Xcode

* Open `ios/Runner.xcworkspace` → select **Runner** → **Info** tab.
* Duplicate `Debug` and `Release` into:

  * `Debug-dev`, `Debug-qa`, `Release-dev`, `Release-qa`.

## 5.3: User-Defined Build Settings

Add in **Build Settings → User-Defined**:

* `APP_DISPLAY_NAME`:

  * Dev: `GameElevate Dev`
  * QA: `GameElevate QA`
  * Prod: `GameElevate`

* `BUNDLE_ID_SUFFIX`:

  * Dev: `.dev`
  * QA: `.qa`
  * Prod: (empty)

## 5.4: Bundle Identifier

```
Debug-dev: com.app$(BUNDLE_ID_SUFFIX)
Debug-qa:  com.app$(BUNDLE_ID_SUFFIX)
Release:   com.app
```

## 5.5: Create Schemes

* `Runner-dev`: maps to Debug-dev / Release-dev
* `Runner-qa`: maps to Debug-qa / Release-qa
* `Runner`: prod scheme

Mark schemes as **Shared**.

## 5.6: Firebase for iOS

* Download separate files:

  * `GoogleService-Info-dev.plist`
  * `GoogleService-Info-qa.plist`
  * `GoogleService-Info-prod.plist`

* Add all to Xcode project.

* Add **Run Script Phase**:

```bash
case "${CONFIGURATION}" in
    *-dev*)
        cp "${PROJECT_DIR}/Runner/GoogleService-Info-dev.plist" \
           "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
    *-qa*)
        cp "${PROJECT_DIR}/Runner/GoogleService-Info-qa.plist" \
           "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
    *)
        cp "${PROJECT_DIR}/Runner/GoogleService-Info-prod.plist" \
           "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
esac
```

---

# 6. Flutter/Dart Flavor Config

## 6.1: `flavor_config.dart`

```dart
enum AppEnvironmentType { dev, qa, prod }

abstract class AppEnvironment {
  static late String environmentName;
  static late AppEnvironmentType _environment;

  static AppEnvironmentType get environment => _environment;

  static void setEnvironment(AppEnvironmentType environment) {
    _environment = environment;
    switch (environment) {
      case AppEnvironmentType.dev:
        environmentName = "Development";
        break;
      case AppEnvironmentType.qa:
        environmentName = "QA";
        break;
      case AppEnvironmentType.prod:
        environmentName = "Production";
        break;
    }
  }
}
```

## 6.2: Entry Points

Example (`main_dev.dart`):

```dart
import 'package:flutter/widgets.dart';
import 'package:your_app/common_main.dart';
import 'package:your_app/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(AppEnvironmentType.dev);
  commonMain();
}
```

Repeat for `main_qa.dart` and `main_prod.dart`.

---

# 7. Build & Run Commands

## Android

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter build apk --flavor qa -t lib/main_qa.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

## iOS

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter build ios --flavor qa -t lib/main_qa.dart --release
```

---

# 8. Firebase Setup

**Android**

* Use one `google-services.json` with multiple clients, or maintain separate ones.

**iOS**

* Use multiple `GoogleService-Info.plist` files.
* Copy correct plist using Run Script Phase.

---

# 9. Testing Checklist

* [ ] Different app names appear per flavor.
* [ ] Different bundle IDs per flavor.
* [ ] Firebase config loads correctly.
* [ ] Android builds succeed with `--flavor`.
* [ ] iOS builds succeed with correct scheme.
* [ ] All schemes are shared and committed to repo.

---

# 10. Common Issues

* **App name not changing (iOS)**: Check `Info.plist` uses `$(APP_DISPLAY_NAME)`.
* **Bundle ID conflicts**: Ensure suffix values are unique.
* **Firebase errors (iOS)**: Verify Run Script Phase copies correct file.
* **APK not found**: Always specify `--flavor` and `-t`.

---

# 11. Quick Reference Commands

```bash
# Clean
flutter clean

# Run Dev (Android)
flutter run --flavor dev -t lib/main_dev.dart

# Build QA (APK)
flutter build apk --flavor qa -t lib/main_qa.dart --release

# Build Prod (iOS)
flutter build ios --flavor prod --release -t lib/main_prod.dart
```

---

✅ With these steps, your Flutter project now supports multiple flavors for both Android and iOS.
