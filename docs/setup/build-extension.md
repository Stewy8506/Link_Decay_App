# Browser Extension Build Guide

LinkShelf can be built as a browser extension. This guide covers target compilation, configuration manifests, Content Security Policy (CSP) enforcement, and local installation instructions.

---

## ✦ 1. Extension Configurations

The build relies on files under the `/web` directory:
- [web/manifest.json](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/web/manifest.json): Configured for **Manifest V3**. Defines extension permissions (such as access to active browser tabs), background worker scripts, and icons.
- [web/index.html](file:///Users/anv./AndroidStudioProjects/Link_Decay_App/web/index.html): Configures the HTML viewport to a fixed size of `400x600px` to fit inside the extension toolbar popup window.

---

## ✦ 2. Compile the Web Asset Bundle

To build the extension, run the compiler with specific web options:

```bash
flutter build web --csp --no-web-resources-cdn
```

### Explaining the Compiler Flags:
- `--no-web-resources-cdn`: Bundles all web static resources (like CanvasKit WebAssembly files) locally inside the build directory to avoid fetching them from a CDN, which violates extension Content Security Policies.
- `--csp`: Enables Content Security Policy compliance by disabling dynamically evaluated script tags. This is **required** by Chrome Extensions Manifest V3 guidelines.

---

## ✦ 3. Load the Extension into Google Chrome

Once compiled, you can load the app directly into your browser:

1. Open Chrome and navigate to `chrome://extensions/`.
2. Toggle on **Developer mode** in the top-right corner.
3. Click **Load unpacked** in the top-left corner.
4. Select the build directory: `build/web/` in your project root.
5. Click the extension icon in the toolbar, select **LinkShelf**, and test page captures.

---

## ✦ 4. Safari Web Extension Adaptation

To port the compiled code to Safari Web Extensions, use Apple's migration tool:
```bash
xcrun safari-web-extension-converter build/web
```
This commands generates an Xcode project wrapping the unpacked web assets for macOS/iOS distribution.
