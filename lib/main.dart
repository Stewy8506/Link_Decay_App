import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/providers.dart';
import 'services/notification_service.dart';
import 'services/share_intent_service.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set initial system UI overlay style (dark mode default).
  // Per-screen overrides are handled by AppBarTheme.systemOverlayStyle.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kSurfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize notifications
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: _ShareIntentWrapper(),
    ),
  );
}

/// Wraps the app to handle share intent initialization after Riverpod is ready.
class _ShareIntentWrapper extends ConsumerStatefulWidget {
  const _ShareIntentWrapper();

  @override
  ConsumerState<_ShareIntentWrapper> createState() => _ShareIntentWrapperState();
}

class _ShareIntentWrapperState extends ConsumerState<_ShareIntentWrapper> {
  @override
  void initState() {
    super.initState();
    _setupShareIntent();
    _scheduleNotifications();
  }

  void _setupShareIntent() {
    ShareIntentService.instance.startListening(
      onUrl: (url) {
        ref.read(linkActionsProvider.notifier).saveLink(url);
      },
    );
  }

  Future<void> _scheduleNotifications() async {
    // Request permission, then schedule if granted.
    final granted = await NotificationService.instance.requestPermissions();
    if (!granted) return;

    final db = ref.read(databaseProvider);
    final settings = await db.getSettings();
    final halfLife = settings?.halfLifeDays ?? 7.0;
    final threshold = settings?.notificationThreshold ?? 0.25;
    final enabled = settings?.notificationsEnabled ?? true;

    if (enabled) {
      await NotificationService.instance.scheduleDailyCheck(
        db: db,
        halfLifeDays: halfLife,
        threshold: threshold,
      );
    }
  }

  @override
  void dispose() {
    ShareIntentService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ReadDecayApp();
  }
}
