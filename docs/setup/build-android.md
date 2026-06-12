# Android Build and Signing Configuration

This guide explains how to configure release signing certificates and compile the production-ready **Android App Bundle (AAB)** for Google Play deployment.

---

## ✦ 1. Configure Target SDK Versions

Double-check version specifications inside the gradle build profile [android/app/build.gradle.kts](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/android/app/build.gradle.kts):
- **Compile SDK**: `34` (Android 14) or higher
- **Target SDK**: `34` (Android 14) or higher
- **Min SDK**: `21` (Android 5.0)

---

## ✦ 2. Generate a Release Signing Key (Keystore)

Android requires an upload certificate key to authenticate app updates on the Google Play Store.

### On macOS / Linux
Open your terminal and run the following command to generate an upload keystore in the `android/app/` folder:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.p12 \
  -storetype PKCS12 -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

### On Windows
```powershell
keytool -genkey -v -keystore android\app\upload-keystore.p12 ^
  -storetype PKCS12 -keyalg RSA -keysize 2048 ^
  -validity 10000 -alias upload
```

> [!WARNING]
> Choose a secure store password. Note the key alias (`upload`) and keep this file safe. If you lose this key, you will not be able to publish updates to your app.

---

## ✦ 3. Configure Signing Properties

To authenticate compilation builds securely without hardcoding keystore passwords in Git:

1. Create a properties file: `android/key.properties` (this file is excluded from git commits by `.gitignore` rules).
2. Populate the file with your credentials:
   ```properties
   storePassword=your_keystore_password_here
   keyPassword=your_keystore_password_here
   keyAlias=upload
   storeFile=upload-keystore.p12
   ```

---

## ✦ 4. Gradle Integration

The Gradle configuration loads the properties file and hooks it into release builds:

```kotlin
// android/app/build.gradle.kts
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## ✦ 5. Compile the Android App Bundle (AAB)

Compile the application into a single `.aab` file:
```bash
flutter build appbundle --release
```

Once compilation completes, the signed asset is located at:
`build/app/outputs/bundle/release/app-release.aab`
