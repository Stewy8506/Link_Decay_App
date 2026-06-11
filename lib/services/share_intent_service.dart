import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Listens to incoming shared text/URLs from the Android share sheet.
class ShareIntentService {
  ShareIntentService._internal();
  static final ShareIntentService instance = ShareIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _streamSub;

  /// Extract the first HTTP/HTTPS URL from a given string, if it exists.
  String? _extractUrl(String text) {
    final regExp = RegExp(r'(https?://[^\s]+)', caseSensitive: false);
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  /// Start listening for shared URLs. [onUrl] is called with each URL received.
  void startListening({required void Function(String url) onUrl}) {
    // Handle URLs shared when the app is already open.
    _streamSub = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> files) {
      for (final file in files) {
        final path = file.path;
        final url = _extractUrl(path);
        if (url != null) {
          onUrl(url);
        }
      }
    }, onError: (Object err) {
      // Catch platform stream errors silently
    });

    // Handle URL shared when app was closed and opened via share sheet.
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> files) {
      for (final file in files) {
        final path = file.path;
        final url = _extractUrl(path);
        if (url != null) {
          onUrl(url);
        }
      }
      // Reset so we don't process the initial share twice.
      ReceiveSharingIntent.instance.reset();
    }).catchError((Object _) {
      // Catch initial load errors silently
    });
  }

  void dispose() {
    _streamSub?.cancel();
  }
}
