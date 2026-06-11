# Guide: Publishing LinkShelf to the Google Play Store

This document outlines the step-by-step workflow required to prepare, sign, build, and deploy the LinkShelf Flutter application to the Google Play Store.

---

## 📋 Table of Contents
1. [Prerequisites](#1-prerequisites)
2. [App Identification & Metadata Verification](#2-app-identification--metadata-verification)
3. [Generate a Release Signing Key (Keystore)](#3-generate-a-release-signing-key-keystore)
4. [Configure Signing in Gradle](#4-configure-signing-in-gradle)
5. [Build the Release App Bundle (AAB)](#5-build-the-release-app-bundle-aab)
6. [Set Up the Play Console & Store Listing](#6-set-up-the-play-console--store-listing)
7. [Deploy to Testing & Production Tracks](#7-deploy-to-testing--production-tracks)
8. [Common Troubleshooting & Play Store Rules](#8-common-troubleshooting--play-store-rules)

---

## 1. Prerequisites
Before starting, ensure you have:
*   A **Google Play Developer Account** (requires a one-time $25 registration fee).
*   **Java Development Kit (JDK)** installed on your machine (specifically `keytool` for keystore generation).
*   The following graphic assets:
    *   **App Icon**: 512x512 px, 32-bit PNG (Max size: 1MB, no alpha channel).
    *   **Feature Graphic**: 1024x500 px, JPG or 24-bit PNG.
    *   **Screenshots**: At least 2-4 screenshots of the app UI (minimum 320px, max 3840px, aspect ratio 16:9 or 9:16).
*   A hosted **Privacy Policy URL** (required for all Play Store listings).

---

## 2. App Identification & Metadata Verification

Double-check that the application's unique ID and settings are correctly configured in `android/app/build.gradle.kts`:

1.  **Application ID**: Ensure `applicationId` is set to `com.linkshelf.decay`.
2.  **Target SDK Version**: Google Play requires target SDK version 34 (Android 14) or higher.
    *   `compileSdk = 34`
    *   `targetSdk = 34`
3.  **App Versioning**: Update the version code and name in `pubspec.yaml` before every release.
    *   Example: `version: 1.0.1+2` (where `1.0.1` is the `versionName` shown to users, and `2` is the `versionCode` used internally by the Play Store to track updates).

---

## 3. Generate a Release Signing Key (Keystore)

The Android system requires all installed applications to be digitally signed with a developer certificate before they can be uploaded to the Play Store.

### On macOS / Linux
Open your terminal and run the following command to generate a upload keystore named `upload-keystore.p12`:

```bash
keytool -genkey -v -keystore ~/upload-keystore.p12 \
  -storetype PKCS12 -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

### On Windows (Command Prompt / PowerShell)
```powershell
keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.p12 ^
  -storetype PKCS12 -keyalg RSA -keysize 2048 ^
  -validity 10000 -alias upload
```

### Important Steps During Keystore Generation:
1.  **Password**: Choose a secure password and remember it. You will need to enter this in the configurations below.
2.  **Details**: Answer the prompts regarding your name, organizational unit, location, etc.
3.  **Storage**: Keep this keystore file safe! If you lose this key file, you will not be able to publish updates to your app.

---

## 4. Configure Signing in Gradle

To tell Flutter and Gradle how to sign your release builds, configure your credentials securely using a `key.properties` file.

### Step A: Create the Properties File
Create a new file named `android/key.properties` in your project root (this file is included in `.gitignore` by default to avoid checking credentials into Git).

Add the following lines, substituting your keystore path and passwords:

```properties
storePassword=your_keystore_password_here
keyPassword=your_keystore_password_here
keyAlias=upload
storeFile=/Users/your_username/upload-keystore.p12
```
*(Windows users: Use forward slashes in path, e.g., `C:/Users/username/upload-keystore.p12`)*

### Step B: Configure Gradle to Load Key Properties
Open `android/app/build.gradle.kts` and modify it to read the `key.properties` file and set up release signing config.

1.  Add the property loading code near the top of the file:

```kotlin
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

2.  Update the `signingConfigs` and `buildTypes` blocks:

```kotlin
android {
    ...
    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Apply the signing config defined above
            signingConfig = signingConfigs.getByName("release")
            
            minifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## 5. Build the Release App Bundle (AAB)

The **Android App Bundle (AAB)** is the modern upload format required by Google Play. Google Play uses AAB to generate optimized, device-specific APKs for each user, reducing download size.

Run the following command in the root of your project:

```bash
flutter build appbundle --release
```

Once compiled, you can find the output app bundle here:
`build/app/outputs/bundle/release/app-release.aab`

---

## 6. Set Up the Play Console & Store Listing

1.  Log in to the [Google Play Console](https://play.google.com/console).
2.  Click **Create app** (top-right).
3.  Fill in the basic app details:
    *   **App name**: LinkShelf
    *   **Default language**: English (United States)
    *   **App or game**: App
    *   **Free or paid**: Free
    *   Agree to the developer declarations and confirm.
4.  Navigate to the **Main store listing** (under *Grow* > *Store presence*):
    *   Provide a **Short description** (up to 80 chars) and **Full description** detailing LinkShelf's local-first design and time-based freshness decay.
    *   Upload your App Icon (512x512) and Feature Graphic (1024x500).
    *   Upload at least 2 screenshots of your phone interface.
    *   Provide your hosted **Privacy Policy URL**.

---

## 7. Deploy to Testing & Production Tracks

For new accounts, Google Play Console requires completing various testing stages before launching to Production.

### Step A: Setup App Integrity
*   Under *Release* > *Setup* > *App integrity*, verify that **Play App Signing** is enabled. Play Console will take care of managing your ultimate production key while you sign with your upload key.

### Step B: Create an Internal / Closed Testing Release
1.  Go to **Testing** > **Closed testing** (or **Internal testing** for immediate deployment without reviews).
2.  Select **Create release**.
3.  Upload the `.aab` file (`build/app/outputs/bundle/release/app-release.aab`).
4.  Specify a release name (e.g., `1.0.0 (1)`) and write short release notes outlining the features.
5.  Save and click **Review release**, then roll out.

### Step C: Production Promotion
*   Once testing is complete and the app has been reviewed, select **Promote release** to transition the bundle from Closed Testing to the **Production** track.

---

## 8. Common Troubleshooting & Play Store Rules

### Google Play's 20-Tester Policy (Crucial for Personal Accounts)
*   **Rule**: If your developer account was created after November 2023, you must run a closed testing track with at least **20 testers** opted-in continuously for at least **14 days** before you can request access to publish your app to Production.
*   **Action**: Recruit 20 friends/testers, add their email addresses to your closed testing track group, and ensure they install and keep the app for two weeks.

### Version Code Rejection
*   If you get an error that the "version code has already been used," increment the build version code in `pubspec.yaml` (the number after the `+` sign) and run `flutter build appbundle --release` again.
    *   *Change:* `1.0.0+1` ➡️ `1.0.0+2`
