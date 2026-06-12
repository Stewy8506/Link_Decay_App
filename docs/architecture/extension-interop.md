# Browser Extension Interoperability

LinkShelf can be compiled as a browser extension popup for Google Chrome, Brave, and Apple Safari (via WebKit Extensions). This allows users to save pages directly from their active browser tab.

This document details the layout adjustments, Javascript Interop bindings, and conditional compilation strategies that enable web compatibility.

---

## ✦ Viewport and Layout Adjustments

The extension runs in a restricted iframe/popup window layout. The UI is locked to a fixed size and inherits phone navigation components:
- **Constraints**: Viewport size is locked to **400px width and 600px height** in `web/index.html` to align with browser popup panel dimensions.
- **Visuals**: Widescreen layouts (like sidebar panels) are suppressed. The app's fluid responsive logic interprets the web window size as a mobile-phone viewport and automatically renders mobile-first sheets and bottom navigation elements.

---

## ✦ Conditional Compilation Architecture

Because native platform runners (Android, macOS, Windows) do not compile with web JS dependencies, the project isolates browser APIs using Dart conditional exports:

```
lib/services/
  ├── extension_service.dart       <--- Entry Point (Conditional exporter)
  ├── extension_service_stub.dart  <--- Stub Fallback (Native targets)
  └── extension_service_web.dart   <--- Web JS Interop (Web targets)
```

### Ingestion Declarations
The entry point `extension_service.dart` uses conditional compilation to decide which implementation file to resolve:

```dart
// lib/services/extension_service.dart
export 'extension_service_stub.dart'
    if (dart.library.js_interop) 'extension_service_web.dart';
```

When building for Windows, macOS, or Android, the compiler loads the stub file which returns dummy values. When targeting the web, the compiler loads the `js_interop` module.

---

## ✦ JS Interop Tab Query Implementation

The extension queries the browser's tab manager to fetch the URL of the active tab. This is written using Dart's modern `dart:js_interop` and `dart:js_interop_unsafe` libraries.

### JS Bindings
The web service maps the underlying `chrome.tabs` browser API directly to typed Dart signatures:

```dart
@JS('chrome.tabs.query')
external JSPromise _chromeTabsQuery(JSObject queryInfo);

@JS('chrome')
external JSAny? get _chrome;
```

### Ingestion Logic
When the user opens the extension, the popup executes a background check:

```dart
Future<String?> getCurrentTabUrl() async {
  if (!isExtension) return null;

  try {
    // Construct query parameters: {active: true, currentWindow: true}
    final queryInfo = {
      'active': true.toJS,
      'currentWindow': true.toJS,
    }.jsify() as JSObject;

    final promise = _chromeTabsQuery(queryInfo);
    final result = await promise.toDart as JSArray?;
    
    if (result != null && result.length > 0) {
      final firstTab = result.toDart.first as JSObject;
      final urlProp = firstTab.getProperty('url'.toJS);
      if (urlProp != null && urlProp.isA<JSString>()) {
        return (urlProp as JSString).toDart;
      }
    }
  } catch (e) {
    debugPrint('ExtensionService error: $e');
  }
  return null;
}
```

This URL is pre-filled inside the URL field of the `AddLinkSheet` widget, allowing users to save the page in a single click.
