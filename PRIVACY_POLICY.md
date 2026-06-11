# Privacy Policy for LinkShelf

Last Updated: June 11, 2026

LinkShelf ("we", "our", or "us") built the LinkShelf mobile application as a local-first utility. This Service is provided at no cost and is intended for use as is.

This page is used to inform users regarding our policies with the collection, use, and disclosure of Personal Information if anyone decides to use our Service.

If you choose to use our Service, then you agree to the collection and use of information in relation to this policy.

## 1. Information Collection and Use

**LinkShelf is an offline, local-first application.** 

- **Local Storage:** All bookmarks, titles, domains, notes, highlights, and custom tags you save or create within the app are stored exclusively on your device's local database (using SQLite/Drift).
- **No Server Storage:** We do not host, run, or communicate with any external database servers. Your reading list and notes never leave your device unless you explicitly choose to export them as an HTML/JSON backup file.
- **Metadata Fetching:** To display titles, cover images, and icons for links you add, the app makes direct HTTP requests from your device to the target website's server to parse their public HTML metadata. No third-party intermediary server tracks this process.
- **Permissions:** The app requests the following system permissions to operate:
  - **Internet:** Required to fetch public metadata (title, favicon, description) of target links you save.
  - **Notifications:** Required to schedule local, device-based check-ins and weekly summaries of your reading stats.
  - **Alarms (Exact Alarms):** Required to run precise time-based scheduling so decay notifications trigger exactly when your links rot.
  All permission processes are run completely locally on your device.

## 2. Third-Party Services

The Service does not use any third-party SDKs, analytic trackers, or advertising frameworks (such as Firebase, Google Analytics, or AdMob) that collect data.

## 3. Security

We value your trust in using our Service. Since all your data is stored locally on your device, the security of your data depends on your device's security settings. We recommend keeping your device operating system updated and using device encryption/screen locks.

## 4. Children’s Privacy

These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone. Since the application does not upload or collect any data, children's data is not transmitted or shared.

## 5. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted.

## 6. Contact Us

If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at the repository owner's GitHub profile.
