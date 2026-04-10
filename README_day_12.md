# Day 12 — Release Preparation & Google Play Store Submission

## Overview

Day 12 covers everything needed to take a Flutter app from development to the Google Play Store. This README is a complete reference guide — follow it for any future app release without confusion.

---

## Part 1 — App Rename & Package ID

### App Display Name
The display name shown on the device home screen is set in `AndroidManifest.xml`:

```xml
android:label="Onward"
```

For this project we renamed from `HabitTracker` → `Onward`.

### Application ID
The application ID is your app's **permanent unique identifier** on Play Store. Once published you can NEVER change it.

Format: `com.yourname.appname`

We used: `com.gokulhari.onward`

This was set in `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    applicationId = "com.gokulhari.onward"
    ...
}
```

### Package Name Change — Critical Steps
When changing the application ID, three things must be updated:

**Step 1 — `pubspec.yaml`:**
```yaml
name: onward
```

**Step 2 — Fix all import paths using VS Code Find & Replace (Ctrl+Shift+H):**
- Find: `package:habit_tracker`
- Replace: `package:onward`
- Click Replace All

**Step 3 — Move `MainActivity.kt` to correct folder:**

The file must live at the path matching your application ID:
```
android/app/src/main/kotlin/com/gokulhari/onward/MainActivity.kt
```

Update the package declaration inside the file:
```kotlin
package com.gokulhari.onward
```

**Step 4 — `android/app/build.gradle.kts`:**
```kotlin
namespace = "com.gokulhari.onward"
applicationId = "com.gokulhari.onward"
```

**Step 5 — `lib/app.dart`:**
```dart
title: 'Onward',
```

**Step 6 — `ios/Runner/Info.plist`:**
```xml
<key>CFBundleName</key>
<string>Onward</string>
```

---

## Part 2 — Keystore Generation (Most Critical Step)

### What is a Keystore?
A keystore is a digital signature file that proves the app on Play Store belongs to you. Think of it as your app's permanent identity certificate.

**CRITICAL RULES:**
- Never delete this file — ever
- Never lose the password — ever
- Back it up to Google Drive, USB, email — multiple places
- If you lose it, you can NEVER update your app on Play Store again

### Generate the Keystore
Run this command in your project root terminal:

```bash
keytool -genkey -v -keystore onward-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias onward-key
```

Answer the prompts:
- Keystore password: choose a strong password
- First and last name: your name
- Organizational unit: Individual
- Organization: your name
- City: your city
- State: your state
- Country code: IN (for India)
- Confirm: yes

**Note:** When typing the password nothing appears on screen — this is normal security behavior. Just type and press Enter.

### Create `android/key.properties`
Create this file in the `android/` folder:

```properties
storePassword=YOUR_PASSWORD_HERE
keyPassword=YOUR_PASSWORD_HERE
keyAlias=onward-key
storeFile=../../onward-release-key.jks
```

**Note:** The `storeFile` path uses `../../` because it goes up from `android/` to the project root where the `.jks` file lives.

### Add to `.gitignore`
**NEVER push the keystore or key.properties to GitHub:**

```
*.jks
*.keystore
key.properties
```

### Configure `android/app/build.gradle.kts`
Full file with signing config:

```kotlin
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

android {
    namespace = "com.gokulhari.onward"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.gokulhari.onward"
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}
```

**Key points:**
- `targetSdk = 35` — Play Store now requires minimum API 35
- `ndkVersion = "27.0.12077973"` — required by flutter_native_splash and sqlite3_flutter_libs
- `isMinifyEnabled = true` — reduces app size significantly
- `isShrinkResources = true` — removes unused resources

---

## Part 3 — Build Release AAB

### What is an AAB?
AAB (Android App Bundle) is the file format Google Play requires for app submission. Unlike APK, Google Play splits the AAB by device architecture so each user downloads only what their device needs — resulting in smaller download sizes.

### Build Command
```bash
flutter build appbundle --release
```

Output location:
```
build/app/outputs/bundle/release/app-release.aab
```

### App Size Reality Check
| Build type | Size |
|------------|------|
| Debug APK (what you see during development) | ~140MB |
| Release AAB (what you upload) | ~43MB |
| What users actually download | ~9-15MB |

The debug size is inflated because it includes development tools. Users only download the optimized release slice for their device.

### Back Up the AAB
Copy `app-release.aab` to Google Drive or Desktop immediately after building.

---

## Part 4 — Google Play Developer Account

### One Time Setup
- Go to: `play.google.com/console`
- Registration fee: $25 USD (one time, lifetime)
- After payment, you can publish unlimited apps forever
- Updates to existing apps are always free

### Identity Verification
Google requires identity verification for new accounts:
- Upload Aadhaar card, PAN card, or Passport
- Verification takes 1-3 days
- Phone number verification unlocks after identity is verified

### Developer Name
Choose carefully — this is what users see on Play Store under your app name. Can be changed later but best to get right from start.

---

## Part 5 — App Name Selection

### Rules for Choosing App Name
- Check Play Store for existing apps with same name
- Avoid generic names like "Habit Tracker" — too common
- Choose something unique, memorable, and matching your app's feel
- The app name on Play Store does NOT need to include keywords — your description handles discoverability

### How Users Find Your App
Users find apps through **keywords in your description**, not your app name. So "Onward" will appear in searches for "habit tracker" because those words are in the description.

### For This App
We chose **Onward** — meaning "forward, keep going, making progress". It matches the core feeling of the app — making progress through daily habits.

---

## Part 6 — Google Play Console Setup

### Required Sections (Complete in This Order)

#### 1. Privacy Policy
Google requires a publicly accessible URL even for offline apps.

**Create using Google Sites (free):**
- Go to `sites.google.com`
- Create blank site
- Add privacy policy text
- Publish with URL like: `sites.google.com/view/onward-privacy-policy`

**Privacy policy template for local-only apps:**
```
Privacy Policy for [App Name]

DATA COLLECTION
[App name] does not collect any personal data.
All data is stored locally on your device only.

NO ACCOUNT REQUIRED
No account or personal information is required.

NO INTERNET CONNECTION REQUIRED
Works completely offline. No data is ever sent to any server.

NO THIRD PARTY SHARING
We collect no data, so we share no data.

CONTACT
Email: youremail@gmail.com
```

#### 2. App Access
Select: "All or most functionality is available without special access"

#### 3. Ads
Select: "No, my app does not contain ads"

#### 4. Content Rating
- Click "Start questionnaire"
- Category: Utility
- Answer No to all questions
- Complete and save

#### 5. Target Audience
Select: "18 and over"

#### 6. Data Safety
Answer No to everything for a local-only app. No data collection = no data safety concerns.

#### 7. Government Apps
Select: "No, this app is not a government app"

#### 8. Financial Features
Select: Not applicable

#### 9. Health
Select: Not applicable

#### 10. App Category & Contact
- Category: Productivity
- Email: your email
- Website: your privacy policy URL

#### 11. Store Listing
Fill in:
- **App name:** Onward - Habit Tracker
- **Short description** (80 chars max)
- **Full description** (4000 chars max)
- **App icon:** 512×512 or 1024×1024 PNG
- **Feature graphic:** 1024×500 PNG (banner shown at top of Play Store page)
- **Screenshots:** minimum 2, maximum 8 phone screenshots

**Feature graphic tip:** Create using Canva (canva.com) with custom size 1024×500px. Dark background + app icon + app name + tagline.

---

## Part 7 — Release Pipeline

### Understanding the Four Tracks

```
Internal Testing → Closed Testing → Open Testing → Production
```

| Track | Purpose | Testers needed | Time |
|-------|---------|----------------|------|
| Internal | Quick sanity check | Up to 100, instant | No wait |
| Closed (Alpha) | Required for production unlock | Min 12, opt-in | 14 days |
| Open (Beta) | Optional public beta | Anyone | Optional |
| Production | Live for everyone | Everyone | After approval |

### Step 1 — Internal Testing Release
Upload your AAB here first to verify everything works. Testers get access within seconds.

### Step 2 — Closed Testing Release (Alpha)
This is **mandatory** for new developer accounts before production access.

**Requirements:**
- At least 12 testers who have **opted in** (not just added)
- Must run for at least **14 days**
- Testers must use the **opt-in link** (not the regular Play Store link)

**Tester opt-in flow:**
1. Go to Play Console → Closed testing → Testers tab
2. Copy the **opt-in URL** (format: `play.google.com/apps/testing/com.yourpackage`)
3. Share this link with your testers
4. Each tester must open the link and click **"Become a tester"**
5. Then install the app via Play Store

**Common mistake:** Sharing the regular Play Store listing link instead of the tester opt-in link. The opt-in link is different and required.

### Step 3 — Send for Review
After publishing closed testing release go to **Publishing overview** → **Send changes for review**.

### Step 4 — Wait 14 Days
- Timer starts automatically when 12th tester opts in
- Do NOT let testers opt out — count must stay at 12+
- No action needed during this period

### Step 5 — Apply for Production
After 14 days:
- Go to Dashboard
- Click **"Apply for production"**
- Answer Google's questionnaire about your closed test
- Submit

### Step 6 — Google Review
- Takes 7-14 days for first submission
- Google checks for policy violations, crashes, misleading content
- You receive email when approved or rejected

### Step 7 — App Goes Live
Once approved your app is live on Play Store for everyone worldwide.

---

## Part 8 — Version Management

### `pubspec.yaml` Version Format
```yaml
version: 1.0.0+1
```

- `1.0.0` = version name (shown to users)
- `+1` = version code (internal, must increment with each upload)

### Rules
- Version code must ALWAYS increase with each new upload
- You cannot upload the same version code twice
- Version name can stay the same but version code must increment

### Example progression:
```yaml
version: 1.0.0+1   # First release
version: 1.0.0+2   # Bug fix, same user-facing version
version: 1.1.0+3   # New features
version: 2.0.0+4   # Major update (V2)
```

---

## Part 9 — Common Errors and Fixes

### "MainActivity class not found"
**Cause:** Application ID changed but MainActivity.kt is still in old folder path.
**Fix:** Move MainActivity.kt to match new application ID folder structure and update package declaration inside the file.

### "Keystore file not found"
**Cause:** Wrong path in `key.properties` storeFile.
**Fix:** Use `../../` prefix if keystore is in project root and key.properties is in `android/` folder.

### "Version code already used"
**Cause:** Trying to upload AAB with same version code as previous upload.
**Fix:** Increment version code in `pubspec.yaml` and rebuild AAB.

### "Target API level must be 35+"
**Cause:** `targetSdk = 34` in build.gradle.kts.
**Fix:** Change to `targetSdk = 35` and rebuild.

### "App not available" when tester tries to install
**Cause:** Tester used wrong link (Play Store listing instead of opt-in link).
**Fix:** Share the correct opt-in link from Closed testing → Testers tab.

### Store listing language errors
**Cause:** Multiple language tabs (en-IN, en-US) with some empty.
**Fix:** Fill required fields (app name, short description, full description) in ALL language tabs that exist.

---

## Part 10 — Play Store Business Model

### Costs
| Item | Cost |
|------|------|
| Developer account | $25 one time, lifetime |
| Publishing apps | Free forever |
| App updates | Free forever |
| Additional apps | Free forever |

### Revenue (if monetizing)
- Google takes 15% of revenue for developers earning under $1M/year
- 30% for higher earners
- Free apps = zero fees ever

### Client Work Model
For client apps, recommend the client creates their own developer account ($25 one time) and you publish on their behalf as an admin. This way they own their app permanently and you get paid for each update separately.

---

## Git Commit

```
feat(release): complete Play Store release preparation and submission

- Rename app from HabitTracker to Onward
- Update application ID to com.gokulhari.onward  
- Update package name across all dart files
- Move MainActivity.kt to correct package folder
- Generate release keystore (onward-release-key.jks)
- Configure build.gradle.kts with signing config
- Update targetSdk to 35 for Play Store compliance
- Build signed release AAB (9.94MB user download size)
- Create Google Play Developer account
- Complete all Play Console required sections
- Create privacy policy on Google Sites
- Design feature graphic using Canva
- Submit app for closed testing with 12 testers
- Closed testing active — 14 day timer running
```

---

## Current Status

| Step | Status |
|------|--------|
| App renamed to Onward | ✅ Done |
| Keystore generated | ✅ Done |
| Release AAB built | ✅ Done |
| Play Console account created | ✅ Done |
| Store listing complete | ✅ Done |
| All required sections filled | ✅ Done |
| Internal testing release | ✅ Done |
| Closed testing release | ✅ Active |
| 12 testers opted in | ✅ Done |
| 14 day timer | ⏳ Running |
| Apply for production | ⏳ After 14 days |
| Google review | ⏳ Pending |
| App live on Play Store | ⏳ ~3-4 weeks from now |