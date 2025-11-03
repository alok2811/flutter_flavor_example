# Flutter Flavors Implementation Guide

This document provides a complete, step-by-step guide for implementing flavors in your Flutter project based on the actual implementation in this codebase.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Project Structure](#2-project-structure)
3. [Flutter/Dart Setup](#3-flutterdart-setup)
4. [Android Setup](#4-android-setup)
5. [iOS Setup](#5-ios-setup)
6. [Build & Run Commands](#6-build--run-commands)
7. [Firebase Configuration (Optional)](#7-firebase-configuration-optional)
8. [Replicating This Setup](#8-replicating-this-setup)
9. [Verification & Testing](#9-verification--testing)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Overview

### What are Flavors?

Flavors in Flutter allow you to build multiple variants of your app from a single codebase. Each flavor has its own:
- App display name
- Bundle ID / Application ID
- API endpoints
- Configuration settings
- Resources (icons, images, etc.)

### Flavors in This Project

This project implements **3 flavors**:
- **dev**: Development environment
- **uat**: User Acceptance Testing / Staging environment
- **prod**: Production environment

Each flavor can be installed side-by-side on the same device since they have unique bundle IDs.

### Quick Start - Run a Flavor

**For Android:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**For iOS:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Replace `dev` with `uat` or `prod` for other flavors.**

---

## 2. Project Structure

### Dart/Flutter Files

```
lib/
├── flavor_config.dart         # Environment configuration
├── common_main.dart           # Shared app initialization
├── main_dev.dart             # Dev flavor entry point
├── main_uat.dart             # UAT flavor entry point
└── main_prod.dart            # Prod flavor entry point
```

### Android Files

```
android/app/
├── build.gradle.kts          # Product flavors definition
└── src/
    └── main/
        └── AndroidManifest.xml  # Uses @string/app_name
```

### iOS Files

```
ios/
├── Runner.xcodeproj/
│   ├── project.pbxproj       # Build configurations
│   └── xcshareddata/
│       └── xcschemes/        # Flavor schemes
│           ├── dev.xcscheme
│           ├── uat.xcscheme
│           └── prod.xcscheme
└── Runner/
    └── Info.plist            # Uses $(APP_DISPLAY_NAME)
```

---

## 3. Flutter/Dart Setup

### 3.1 Create `flavor_config.dart`

Location: `lib/flavor_config.dart`

This file defines the environment enum and configuration for each flavor.

```dart
enum Environment { dev, uat, prod }

abstract class AppEnvironment {
  static late String environmentName;
  static late String baseUrl;

  static late Environment _environment;

  static Environment get environment => _environment;
  
  static void setEnvironment(Environment environment) {
    _environment = environment;
    switch (environment) {
      case Environment.dev:
        environmentName = "Development";
        baseUrl = "https://dev.example.com";
        break;
      case Environment.uat:
        environmentName = "Staging";
        baseUrl = "https://staging.example.com";
        break;
      case Environment.prod:
        environmentName = "Production";
        baseUrl = "https://prod.example.com";
        break;
    }
  }
}
```

**Key Points:**
- Defines 3 environments: dev, uat, prod
- Stores environment-specific configuration (names, URLs, etc.)
- Provides static methods to set and retrieve current environment

### 3.2 Create `common_main.dart`

Location: `lib/common_main.dart`

This file contains the shared app initialization code.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_flavor_example/flavor_config.dart';

void commonMain() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times: ${AppEnvironment.environmentName}',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Key Points:**
- Contains all the shared app logic
- Uses `AppEnvironment.environmentName` to display current flavor
- Called by each flavor-specific entry point

### 3.3 Create Entry Points

**`main_dev.dart`**
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_flavor_example/common_main.dart';
import 'package:flutter_flavor_example/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(Environment.dev);
  commonMain();
}
```

**`main_uat.dart`**
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_flavor_example/common_main.dart';
import 'package:flutter_flavor_example/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(Environment.uat);
  commonMain();
}
```

**`main_prod.dart`**
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_flavor_example/common_main.dart';
import 'package:flutter_flavor_example/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(Environment.prod);
  commonMain();
}
```

**Key Points:**
- Each entry point sets the environment BEFORE calling `commonMain()`
- Same pattern for all flavors, just different environment values
- `WidgetsFlutterBinding.ensureInitialized()` is called first

---

## 4. Android Setup

### 4.1 Gradle Configuration (Kotlin DSL)

**File:** `android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_flavor_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_flavor_example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }

        flavorDimensions += "default"
        productFlavors {
            create("dev") {
                dimension = "default"
                resValue(
                    type = "string",
                    name = "app_name",
                    value = "Flavors Dev"
                )
                applicationIdSuffix = ".dev"
            }

            create("uat") {
                dimension = "default"
                resValue(
                    type = "string",
                    name = "app_name",
                    value = "Flavors UAT"
                )
                applicationIdSuffix = ".uat"
            }
            
            create("prod") {
                dimension = "default"
                resValue(
                    type = "string",
                    name = "app_name",
                    value = "Flavors"
                )
            }
        }
    }
}

flutter {
    source = "../.."
}
```

**Key Points:**
- **`flavorDimensions`**: Defines dimension for flavors (required by Android)
- **`productFlavors`**: Defines dev, uat, and prod flavors
- **`resValue`**: Sets app name for each flavor (used by AndroidManifest.xml)
- **`applicationIdSuffix`**: Adds `.dev` or `.uat` suffix (prod has no suffix)
  - Final App IDs: 
    - Dev: `com.example.flutter_flavor_example.dev`
    - UAT: `com.example.flutter_flavor_example.uat`
    - Prod: `com.example.flutter_flavor_example`

### 4.2 AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="@string/app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

**Key Points:**
- `android:label="@string/app_name"` uses the value from `resValue` in build.gradle.kts
- This allows each flavor to have a different app name

### 4.3 No Separate Flavor Directories Needed

**Important:** Unlike some older setups, this project does **NOT** require separate directories like:
- `android/app/src/dev/AndroidManifest.xml`
- `android/app/src/uat/AndroidManifest.xml`

The Gradle configuration handles everything automatically via `resValue`.

---

## 5. iOS Setup

iOS flavor setup is more complex than Android and requires manual Xcode configuration.

### 5.1 Info.plist Configuration

**File:** `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>$(APP_DISPLAY_NAME)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<!-- ... other keys ... -->
</dict>
</plist>
```

**Key Points:**
- `CFBundleDisplayName` uses `$(APP_DISPLAY_NAME)` variable
- This variable is set per build configuration in Xcode

### 5.2 Xcode Build Configurations

The iOS setup requires **manual configuration in Xcode**:

#### Build Configurations Created

Each flavor has 3 build configurations:
- `Debug-{flavor}`
- `Release-{flavor}`
- `Profile-{flavor}`

**Total: 9 configurations**
- Debug-dev, Release-dev, Profile-dev
- Debug-uat, Release-uat, Profile-uat
- Debug-prod, Release-prod, Profile-prod

#### Build Settings Per Configuration

**Debug-dev:**
```
APP_DISPLAY_NAME = "Flavors Dev"
PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterFlavorExample.dev
SWIFT_OPTIMIZATION_LEVEL = "-Onone"  (for debugging)
```

**Debug-uat:**
```
APP_DISPLAY_NAME = "Flavors Uat"
PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterFlavorExample.uat
SWIFT_OPTIMIZATION_LEVEL = "-Onone"
```

**Debug-prod:**
```
APP_DISPLAY_NAME = Flavors
PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterFlavorExample
SWIFT_OPTIMIZATION_LEVEL = "-Onone"
```

### 5.3 Xcode Schemes

**Location:** `ios/Runner.xcodeproj/xcshareddata/xcschemes/`

Three schemes are defined:
- **dev.xcscheme**: Uses Debug-dev / Release-dev
- **uat.xcscheme**: Uses Debug-uat / Release-uat
- **prod.xcscheme**: Uses Debug-prod / Release-prod

**Example: dev.xcscheme**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1630" version="1.7">
   <BuildAction>...</BuildAction>
   <TestAction buildConfiguration="Debug-dev">...</TestAction>
   <LaunchAction buildConfiguration="Debug-dev">...</LaunchAction>
   <ProfileAction buildConfiguration="Release-dev">...</ProfileAction>
   <AnalyzeAction buildConfiguration="Debug-dev">...</AnalyzeAction>
   <ArchiveAction buildConfiguration="Release-dev">...</ArchiveAction>
</Scheme>
```

**Key Points:**
- Each scheme maps actions to specific build configurations
- Launch and Test use Debug, Archive uses Release

---

## 6. Build & Run Commands

### 6.1 Android Commands

**Run Dev**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Run UAT**
```bash
flutter run --flavor uat -t lib/main_uat.dart
```

**Run Prod**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

**Build APK - Dev**
```bash
flutter build apk --flavor dev -t lib/main_dev.dart --release
```

**Build APK - UAT**
```bash
flutter build apk --flavor uat -t lib/main_uat.dart --release
```

**Build APK - Prod**
```bash
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

**Build App Bundle - Prod (Play Store)**
```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

**Key Points:**
- **Always specify `--flavor` AND `-t` together**
- The `-t` flag points to the correct entry point
- APK files are for direct installation, App Bundle is for Play Store

### 6.2 iOS Commands

**Run Dev**
```bash
flutter run --flavor dev -t lib/main_dev.dart
# Xcode will use the "dev" scheme automatically
```

**Run UAT**
```bash
flutter run --flavor uat -t lib/main_uat.dart
```

**Run Prod**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

**Build iOS - Dev**
```bash
flutter build ios --flavor dev -t lib/main_dev.dart --release
```

**Build iOS - Prod (for App Store)**
```bash
flutter build ios --flavor prod -t lib/main_prod.dart --release
```

**Archive in Xcode (Alternative)**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select appropriate scheme (dev/uat/prod) from dropdown
3. Product → Archive

**Key Points:**
- Flutter automatically uses the correct Xcode scheme based on flavor
- The scheme is determined by the `--flavor` flag

### 6.3 Clean Build

If you encounter build issues:

```bash
flutter clean
flutter pub get
# Then run your flavor-specific command
```

---

## 7. Firebase Configuration (Optional)

This project does not currently use Firebase, but here's how to add it:

### 7.1 Android Firebase Setup

**Option 1: Single google-services.json**

Add Firebase to your Android app with package IDs:
- `com.example.flutter_flavor_example.dev`
- `com.example.flutter_flavor_example.uat`
- `com.example.flutter_flavor_example` (prod)

Download `google-services.json` and place in `android/app/`

**Option 2: Per-Flavor Files**

Create flavor-specific directories:
```
android/app/src/dev/
    google-services.json
android/app/src/uat/
    google-services.json
android/app/src/prod/
    google-services.json
```

### 7.2 iOS Firebase Setup

**Per-Flavor Files:**

```
ios/Runner/
    GoogleService-Info-dev.plist
    GoogleService-Info-uat.plist
    GoogleService-Info-prod.plist
```

**Run Script Phase in Xcode:**

1. Open Xcode → Select Runner target
2. Build Phases → + → New Run Script Phase
3. Add script:

```bash
case "${CONFIGURATION}" in
    *-dev*)
        cp "${PROJECT_DIR}/Runner/GoogleService-Info-dev.plist" \
           "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
    *-uat*)
        cp "${PROJECT_DIR}/Runner/GoogleService-Info-uat.plist" \
           "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
    *)
        cp "${PROJECT_DIR}/Runner/GoogleService-Info-prod.plist" \
           "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
esac
```

**Key Points:**
- Script runs during build
- Copies correct file based on build configuration
- iOS bundle IDs must match in Firebase console

---

## 8. Replicating This Setup

### Step-by-Step Guide to Add Flavors to a New Project

#### Step 1: Create Flutter Files

1. Create `lib/flavor_config.dart` with environment enum
2. Move existing `main.dart` content to `lib/common_main.dart`
3. Create `lib/main_dev.dart`, `lib/main_uat.dart`, `lib/main_prod.dart`
4. Update import statements with your package name

#### Step 2: Android Setup

1. Open `android/app/build.gradle.kts` (or `.gradle` for Groovy)
2. Add `flavorDimensions` and `productFlavors` inside `android {}` block
3. Set `resValue` for app name and `applicationIdSuffix` per flavor
4. Update `android/app/src/main/AndroidManifest.xml` to use `@string/app_name`

**Verify:**
```bash
cd android
./gradlew tasks --all | grep flavor
# Should show: assembleDev, assembleUat, assembleProd
```

#### Step 3: iOS Setup (Most Complex)

**Option A: Manual in Xcode**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project → **Info** tab
3. Under Configurations:
   - Duplicate Debug → Debug-dev, Debug-uat
   - Duplicate Release → Release-dev, Release-uat
   - Duplicate Profile → Profile-dev, Profile-uat
4. For each configuration, set:
   - `APP_DISPLAY_NAME`
   - `PRODUCT_BUNDLE_IDENTIFIER`
5. Create schemes:
   - Product → Scheme → Manage Schemes
   - Duplicate Runner → dev, uat
   - Configure each scheme to use correct build configurations
   - Check "Shared" checkbox
6. Update `ios/Runner/Info.plist`:
   - Change `CFBundleDisplayName` to `$(APP_DISPLAY_NAME)`

**Option B: Automated Script** (recommended for multiple projects)

Create a script to generate configurations. Example structure:

```bash
# ios/tool/setup_flavors.sh
# Duplicates configurations and updates settings
```

#### Step 4: Test All Flavors

**Android:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor uat -t lib/main_uat.dart
flutter run --flavor prod -t lib/main_prod.dart
```

**iOS:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor uat -t lib/main_uat.dart
flutter run --flavor prod -t lib/main_prod.dart
```

---

## 9. Verification & Testing

### Checklist

#### App Names
- [ ] Dev app displays "Flavors Dev" on home screen
- [ ] UAT app displays "Flavors UAT" on home screen
- [ ] Prod app displays "Flavors" on home screen

#### Bundle/Application IDs
- [ ] Dev: Can install `.dev` app without conflicts
- [ ] UAT: Can install `.uat` app without conflicts
- [ ] Prod: Can install prod app without conflicts
- [ ] All three can be installed side-by-side

#### Environment Configuration
- [ ] Dev shows "Development" in the app
- [ ] UAT shows "Staging" in the app
- [ ] Prod shows "Production" in the app
- [ ] API endpoints are correct per flavor

#### Android Build Variants
```bash
cd android
./gradlew tasks --all | grep -E "assemble|install"
# Should show: devDebug, uatDebug, prodDebug, etc.
```

#### iOS Build Configurations
1. Open `ios/Runner.xcworkspace`
2. Product → Scheme → Manage Schemes
3. Verify dev, uat, prod schemes exist and are Shared
4. Check that each scheme uses correct configurations

---

## 10. Troubleshooting

### Common Issues and Solutions

#### Issue 1: "App name not changing on iOS"
**Symptoms:** All flavors show same app name on iOS

**Solution:**
1. Check `ios/Runner/Info.plist` uses `$(APP_DISPLAY_NAME)`
2. Verify each build configuration sets `APP_DISPLAY_NAME`
3. Clean build: `flutter clean` then rebuild
4. In Xcode, Product → Clean Build Folder

#### Issue 2: "Unable to install app, conflict with existing app"
**Symptoms:** Can only install one flavor at a time

**Solution:**
1. Verify `applicationIdSuffix` in `build.gradle.kts`
2. Check bundle IDs in Xcode are unique:
   - Dev: `com.example.app.dev`
   - UAT: `com.example.app.uat`
   - Prod: `com.example.app`
3. Uninstall all flavors, then reinstall

#### Issue 3: "No flavor named 'dev'"
**Symptoms:** Flutter command fails with flavor error

**Solution:**
1. Verify `build.gradle.kts` has `productFlavors` block
2. Ensure `flavorDimensions` is defined
3. Run `flutter clean && flutter pub get`
4. Check spelling matches exactly

#### Issue 4: "Xcode scheme not found"
**Symptoms:** iOS build fails to find scheme

**Solution:**
1. Open Xcode → Manage Schemes
2. Check "Shared" for all flavor schemes
3. Verify scheme names match: dev, uat, prod (lowercase)
4. Close and reopen Xcode project

#### Issue 5: "Android build variant not found"
**Symptoms:** Gradle can't find flavor variant

**Solution:**
1. Verify `build.gradle.kts` syntax is correct
2. Check `flavorDimensions` is inside `buildTypes` block
3. Sync Gradle files
4. In Android Studio: File → Sync Project with Gradle Files

#### Issue 6: "Wrong environment shown in app"
**Symptoms:** App shows incorrect environment name

**Solution:**
1. Verify `WidgetsFlutterBinding.ensureInitialized()` is called first
2. Check environment is set BEFORE `commonMain()`
3. Ensure correct entry point is used in command
4. Clean and rebuild

#### Issue 7: "Firebase not working per flavor (iOS)"
**Symptoms:** Firebase features fail on iOS

**Solution:**
1. Verify Run Script Phase exists in Xcode
2. Check script copies correct `.plist` file
3. Verify bundle IDs match in Firebase console
4. Ensure script runs before "Copy Bundle Resources"

---

## Quick Reference

### Command Cheat Sheet

```bash
# Clean and prepare
flutter clean && flutter pub get

# Android - Run flavors
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor uat -t lib/main_uat.dart
flutter run --flavor prod -t lib/main_prod.dart

# Android - Build APKs
flutter build apk --flavor dev -t lib/main_dev.dart --release
flutter build apk --flavor uat -t lib/main_uat.dart --release
flutter build apk --flavor prod -t lib/main_prod.dart --release

# Android - Build App Bundle
flutter build appbundle --flavor prod -t lib/main_prod.dart --release

# iOS - Run flavors
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor uat -t lib/main_uat.dart
flutter run --flavor prod -t lib/main_prod.dart

# iOS - Build flavors
flutter build ios --flavor dev -t lib/main_dev.dart --release
flutter build ios --flavor uat -t lib/main_uat.dart --release
flutter build ios --flavor prod -t lib/main_prod.dart --release

# Verify Android variants
cd android && ./gradlew tasks --all | grep flavor
```

### File Locations Summary

| File | Location | Purpose |
|------|----------|---------|
| flavor_config.dart | `lib/` | Environment configuration |
| common_main.dart | `lib/` | Shared app initialization |
| main_*.dart | `lib/` | Entry points per flavor |
| build.gradle.kts | `android/app/` | Product flavors definition |
| AndroidManifest.xml | `android/app/src/main/` | Uses flavor-based app name |
| Info.plist | `ios/Runner/` | Uses flavor-based app name |
| project.pbxproj | `ios/Runner.xcodeproj/` | Build configurations |
| *.xcscheme | `ios/Runner.xcodeproj/xcshareddata/xcschemes/` | Schemes per flavor |

---

## Additional Resources

- [Flutter Flavors Documentation](https://docs.flutter.dev/deployment/flavors)
- [Android Product Flavors](https://developer.android.com/studio/build/build-variants)
- [Xcode Build Configurations](https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project)

---

**Last Updated:** Based on Flutter Flavor Example project analysis
**Flutter Version:** Compatible with Flutter 3.7.2+
**Platforms:** Android, iOS

