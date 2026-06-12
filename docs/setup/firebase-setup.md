# Firebase Integration Setup

LinkShelf uses **Google Firebase** to power user authentication and cloud database synchronization. This guide walks you through creating a Firebase project and configuring the credentials in your local repository.

---

## ✦ 1. Create a Firebase Project

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `linkshelf-app` (or your preferred name).
3. Select whether to enable Google Analytics (not required for local development).
4. Click **Create Project** and wait for provisioning to finish.

---

## ✦ 2. Configure Database & Auth Services

In the Firebase Console sidebar, configure the following services:

### A. Authentication
1. Go to **Build > Authentication** and click **Get Started**.
2. Under the **Sign-in method** tab, enable the following providers:
   - **Anonymous**: Enable and save (powers instant transparent logins).
   - **Google**: Enable, choose a support email, and save (powers account linking).

### B. Cloud Firestore
1. Go to **Build > Firestore Database** and click **Create Database**.
2. Select **Start in test mode** (you will deploy secure rules later).
3. Select a database location closest to your target users and click **Create**.

---

## ✦ 3. Generate Client Credentials (FlutterFire)

To connect the Flutter client, use the FlutterFire CLI tool to generate the platform configurations automatically.

1. **Install Firebase CLI Tools** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Authenticate with Firebase**:
   ```bash
   firebase login
   ```

3. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Configure Platforms**:
   Run the configurator in the root of your project directory:
   ```bash
   flutterfire configure --platforms=android,macos,web
   ```
   - Select the Firebase project you created in Step 1.
   - The CLI will generate `lib/firebase_options.dart` containing API keys and identifiers for each client target.

---

## ✦ 4. Deploy Database Security Rules

Deploy the path-isolated security rules to protect user data.

1. Install the firebase-tools workspace wrapper if needed:
   ```bash
   npx -y firebase-tools@latest deploy --only firestore:rules
   ```
2. Alternatively, copy the contents of the local [firestore.rules](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/firestore.rules) file, paste it directly into the **Rules** tab of your Firestore Database console, and click **Publish**.
