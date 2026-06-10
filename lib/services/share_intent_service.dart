import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Listens to incoming shared text/URLs from the Android share sheet.
class ShareIntentService {
  ShareIntentService._();
  static const ShareIntentService instance = ShareIntentService._();

  StreamSubscription<String>? _streamSub;

  /// Start listening for shared URLs. [onUrl] is called with each URL received.
  void startListening({required void Function(String url) onUrl}) {
    // Handle URLs shared when the app is already open.
    _streamSub = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> files) {
      for (final file in files) {
        final path = file.path;
        if (_looksLikeUrl(path)) {
          onUrl(path);
        }
      }
    });

    // Handle URL shared when app was closed and opened via share sheet.
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> files) {
      for (final file in files) {
        final path = file.path;
        if (_looksLikeUrl(path)) {
          onUrl(path);
        }
      }
      // Reset so we don't process the initial share twice.
      ReceiveSharingIntent.instance.reset();
    });
  }

  bool _looksLikeUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  void dispose() {
    _streamSub?.cancel();
  }
}
