import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';

@JS('chrome.tabs.query')
external JSPromise _chromeTabsQuery(JSObject queryInfo);

@JS('chrome')
external JSAny? get _chrome;

class ExtensionService {
  ExtensionService._internal();
  static final ExtensionService instance = ExtensionService._internal();

  /// Returns true if the app is currently running inside a Chrome extension popup
  bool get isExtension => kIsWeb && _chrome != null && _chrome.isDefinedAndNotNull;

  /// Retrieves the current active tab's URL. Returns null if not in an extension or fails.
  Future<String?> getCurrentTabUrl() async {
    if (!isExtension) return null;

    try {
      // Query {active: true, currentWindow: true}
      final queryInfo = {
        'active': true.toJS,
        'currentWindow': true.toJS,
      }.jsify() as JSObject;

      final promise = _chromeTabsQuery(queryInfo);
      final result = await promise.toDart as JSArray?;
      
      if (result != null && result.length > 0) {
        final firstTab = result.toDart.first as JSObject;
        // Tab object has 'url' property
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
}
