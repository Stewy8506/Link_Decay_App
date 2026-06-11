# Google Play Store Publishing Guide

This guide describes the step-by-step procedure required to configure release credentials, generate assets, compile production-ready bundles, and publish **LinkShelf** on the Google Play Store.

---

## ✦ Step 1: Generate a Keystore (Signing Key)

Every Android app published on Google Play must be signed with a release keystore. 

Open your terminal, navigate to the `android/app` directory (or use an absolute path for the keystore output), and run the Java `keytool` command:

```bash
keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> [!WARNING]
> Keep the keystore file `release-keystore.jks` and its passwords extremely secure! If you lose the key or password, you will not be able to publish updates to your application. Do NOT commit the keystore file to version control.

---

## ✦ Step 2: Configure Release Credentials

1. Open [android/key.properties](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/android/key.properties).
2. Populate the template fields with your keystore credentials:

```properties
storePassword=your-keystore-password
keyPassword=your-alias-key-password
keyAlias=upload
storeFile=release-keystore.jks
```

*(If you store the `release-keystore.jks` file in a directory other than `android/app`, make sure `storeFile` reflects the correct absolute path).*

---

## ✦ Step 3: Generate Custom Launcher Icons

1. Create a design for the app icon (ideally `1024x1024` pixels).
2. Save your icon at `assets/icon/app_icon.png`.
3. Save the foreground asset for the adaptive icon (transparent background) at `assets/icon/app_icon_foreground.png`.
4. Run the following command to automatically generate all required mipmap resource folders for Android and assets catalog folders for iOS:

```bash
flutter pub get
dart run flutter_launcher_icons
```

---

## ✦ Step 4: Build the Production App Bundle

Run the following commands in the workspace root to clean cache, download dependencies, and compile the signed Android App Bundle (AAB):

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

- **Output Location**: `/Users/anv./AndroidStudioProjects/Link_Decay_App/build/app/outputs/bundle/release/app-release.aab`
- **Asset Size**: The App Bundle has code minification and resource shrinking enabled automatically via ProGuard/R8 to guarantee the smallest footprint.

---

## ✦ Step 5: Google Play Store Console Steps

1. **Create an Application**: Log in to [Google Play Console](https://play.google.com/console), click **Create App**, and fill out the basic metadata.
2. **Setup Task List**: Complete the required steps in the console (Declare permissions, specify Content Rating, choose Category).
   - *Note*: LinkShelf uses local storage. Declare that the app does not collect user data to simplify the Data Safety form.
3. **Upload Bundle**: Create a release under **Testing** (Internal or Closed tracks) or **Production** and upload `app-release.aab`.
4. **App Store Listing**:
   - **Screenshots**: Prepare at least 4-8 screenshots showing the Inbox, Stacked Folders grid, and Stats Dashboard.
   - **Privacy Policy**: Host a basic privacy policy website and link it in the store settings.
