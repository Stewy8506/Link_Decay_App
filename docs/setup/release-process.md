# Google Play Release Process

This document details the workflow for uploading compiled binaries (`.aab`) to the Google Play Store, managing release version codes, and navigating Google Play policies.

---

## ✦ 1. Version Increment Rules

Google Play will reject uploads with duplicate version codes. Before building a release, you must increment the build configuration inside `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- **Version Name (`1.0.0`)**: The semantic version string visible to users.
- **Version Code (`1`)**: The internal rank number used by the Play Store to track updates. Must increment by 1 for every build (e.g. `1.0.0+2`, `1.0.1+3`).

---

## ✦ 2. Google Play Store Console Steps

1. Log in to the [Google Play Console](https://play.google.com/console).
2. Click **Create app** and complete the initial declarations (App name, Language, Free utility, etc.).
3. Complete all mandatory configuration tasks under the Console Dashboard:
   - **Privacy Policy**: Provide a hosted URL to [PRIVACY_POLICY.md](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/PRIVACY_POLICY.md).
   - **Data Safety**: Declare that all database sync and credentials remain isolated to user-owned Firestore instances.
   - **Ads / Content Ratings**: Declare the utility contains no advertisements.

---

## ✦ 3. Prepare Store Listing Visuals

Before submitting for review, compile the required visual assets:
- **App Icon**: 512x512 px PNG (Max 1MB).
- **Feature Graphic**: 1024x500 px JPEG/PNG.
- **Device Screenshots**: At least 2-4 screenshots of your phone/tablet layout interface.

---

## ✦ 4. Navigate the 20-Tester Policy (Mandatory)

> [!IMPORTANT]
> **Google Play Policy**: Personal developer accounts registered after **November 2023** must run a closed testing track with at least **20 active testers** opted-in continuously for at least **14 days** before they can request access to publish their app to Production.

### Closed Testing Setup Checklist:
1. In the console, navigate to **Release > Testing > Closed testing**.
2. Click **Create release** and upload the signed `.aab` file.
3. Under the **Testers** tab, create a list of email addresses or associate a Google Group containing your testers.
4. Distribute the provided testing link (Web/Android URL) to your testers.
5. **Monitor Engagement**: Testers must keep the application installed on their devices for 14 consecutive days. Ensure you track the progress dashboard in the console before applying for production promotion.

---

## ✦ 5. CI/CD Release Automation & Secrets

LinkShelf includes a automated release pipeline configured in [release.yml](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/.github/workflows/release.yml). The pipeline automatically builds **Android App Bundles**, **macOS Desktop binaries**, and **Chrome Extension ZIPs**, and uploads them to a **Draft GitHub Release**.

### Repository Secrets Setup
To sign Android builds during compilation, configure the following secrets under your GitHub repository:
1. Go to **Settings > Secrets and variables > Actions** in your GitHub repository.
2. Add a new repository secret:
   - **Name**: `ANDROID_KEYSTORE_BASE64`
   - **Value**: The base64-encoded string of your `upload-keystore.p12` file.
     * To generate this on macOS/Linux, run:
       ```bash
       base64 -i android/app/upload-keystore.p12 | pbcopy
       ```
     * On Windows:
       ```powershell
       [Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/upload-keystore.p12")) | clip
       ```
3. Add another repository secret:
   - **Name**: `ANDROID_KEY_PROPERTIES`
   - **Value**: The exact text of your secure `android/key.properties` file:
     ```properties
     storePassword=your_keystore_password_here
     keyPassword=your_keystore_password_here
     keyAlias=upload
     storeFile=upload-keystore.p12
     ```

### Execution Strategy
- **Automatic Tag Trigger**: Pushing any tag starting with `v` (e.g. `git tag v1.0.1` and `git push origin v1.0.1`) triggers the build pipeline.
- **Manual Trigger**: Under the **Actions** tab of your GitHub repository, select **Release Compilation**, click **Run workflow**, and specify your release tag name.
- **Keystore Fallback**: If the signing secrets are missing in the repository, the compiler automatically falls back to debug signing configs, allowing the build step to succeed.

