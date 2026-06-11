# Walkthrough: Google Play Store Release Preparation for LinkShelf

We have successfully prepared the LinkShelf application for release signing and built the production **Android App Bundle (AAB)**.

## Changes Completed

1. **Keystore Generation**: Generated a release upload keystore `upload-keystore.p12` in the `android/app/` folder.
2. **Signing Configuration**: Configured [key.properties](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/android/key.properties) with the keystore details and credentials.
3. **Gitignore Protection**: Added `**/*.p12` to [android/.gitignore](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/android/.gitignore) to ensure credentials are never checked into git.
4. **App Bundle Compiled**: Ran the release build to compile the app bundle:
   * **Output Location**: [app-release.aab](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/build/app/outputs/bundle/release/app-release.aab) (50.0 MB)

---

## 🚀 Step-by-Step Play Console Upload Guide

Follow these steps to upload your built `.aab` file and complete the publishing process:

### 1. Log in & Create the App
1. Go to the [Google Play Console](https://play.google.com/console).
2. Click **Create app** in the top-right corner.
3. Fill in the general application info:
   * **App name**: LinkShelf
   * **Default language**: English (United States)
   * **App or game**: App
   * **Free or paid**: Free
   * Complete the declarations, accept terms, and click **Create app**.

### 2. Complete the Set Up App Tasks
In the **Dashboard**, complete all mandatory tasks under the "Set up your app" section:
* **Privacy Policy**: Provide a URL to your Privacy Policy. (You can use the local [PRIVACY_POLICY.md](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/PRIVACY_POLICY.md) file to publish online via GitHub Pages, Netlify, or another host).
* **App Access**: Declare if any parts of your app require login/access credentials (LinkShelf is local-first, so declare that all functionality is available without special access).
* **Ads**: Declare that your app does not contain ads.
* **Content Rating**: Complete the questionnaire to get a rating (e.g., standard Utility/Productivity rating).
* **Target Audience**: Select age target (typically 13+ or 18+).
* **News Apps**: Declare that your app is not a news app.
* **COVID-19 Contact Tracing**: Declare that your app is not a contact tracing or status app.
* **Data Safety**: Declare data collection policies (LinkShelf is local-first and does not collect or transmit user data to external servers).
* **Government Apps**: Declare that the app does not represent a government entity.
* **Financial Features**: Select "My app doesn't provide any financial features".

### 3. Setup Store Presence
Under **Grow > Store presence > Main store listing**:
* **Short Description**: A local-first reading list with time-based freshness decay.
* **Full Description**: Present the features of LinkShelf, including local SQLite storage (Drift), auto-categorization, custom tags, sharing integrations, and custom notification systems.
* **Graphics**:
  * **App Icon**: 512x512 px PNG (max 1MB).
  * **Feature Graphic**: 1024x500 px JPEG/PNG.
  * **Screenshots**: At least 2 screenshots showing the app's interfaces.

### 4. Create an Internal or Closed Test Release
1. In the left panel, navigate to **Release > Testing > Closed testing** (or **Internal testing** for instant rollout).
2. Click **Create release** in the top-right.
3. Upload the `.aab` file: [app-release.aab](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/build/app/outputs/bundle/release/app-release.aab)
4. Specify release name (e.g., `1.0.0 (1)`) and write brief release notes.
5. Click **Next** / **Save**, review the release, and click **Start roll-out**.

> [!WARNING]
> **Google Play 20-Tester Policy**: If your personal developer account was registered after November 2023, you must run a closed testing track with at least **20 testers** opted-in continuously for at least **14 days** before you can promote your app to the Production track. Ensure you set up a Google Group or email list in the "Testers" tab of your Closed Testing track to add your testers.
