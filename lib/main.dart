import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'services/auth_service.dart';
import 'services/migration_service.dart';
import 'services/notification_service.dart';
import 'services/share_intent_service.dart';
import 'utils/constants.dart';
import 'data/database.dart' as drift;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Silent anonymous login on boot
    final authService = AuthService.instance;
    var user = authService.currentUser;
    if (user == null) {
      final credential = await authService.signInAnonymously();
      user = credential.user;
    }

    if (user != null) {
      // Run SQLite migration in the background
      final legacyDb = drift.AppDatabase();
      MigrationService.instance.checkAndMigrate(legacyDb, user.uid).then((_) {
        legacyDb.close();
      });
    }
  } catch (e, stack) {
    debugPrint('Firebase initialization / migration failed: $e\n$stack');
  }

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set initial system UI overlay style (dark mode default).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kSurfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize notifications
  try {
    await NotificationService.instance.initialize();
  } catch (e, stack) {
    debugPrint('Failed to initialize notifications: $e\n$stack');
  }

  runApp(const ProviderScope(child: _ShareIntentWrapper()));
}

/// Wraps the app to handle share intent initialization after Riverpod is ready.
class _ShareIntentWrapper extends ConsumerStatefulWidget {
  const _ShareIntentWrapper();

  @override
  ConsumerState<_ShareIntentWrapper> createState() =>
      _ShareIntentWrapperState();
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
      onUrl: (url) async {
        await ref.read(linkActionsProvider.notifier).saveLink(url);
        final isForeground =
            WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
        if (isForeground) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Saved link: $url'),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          String domain = url;
          try {
            final uri = Uri.parse(url);
            domain = uri.host.replaceFirst('www.', '');
          } catch (_) {}

          await NotificationService.instance.showImmediateNotification(
            'Link Saved',
            'Saved $domain to your Inbox.',
          );
        }
      },
    );
  }

  Future<void> _scheduleNotifications() async {
    try {
      // Request permission, then schedule if granted.
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) return;

      // We read settings from settingsProvider
      final settings = ref.read(settingsProvider).valueOrNull;
      final halfLife = settings?.halfLifeDays ?? 7.0;
      final threshold = settings?.notificationThreshold ?? 0.25;
      final enabled = settings?.notificationsEnabled ?? true;
      final decayCurve = settings?.decayCurveType ?? 'exponential';

      if (enabled) {
        await NotificationService.instance.scheduleDailyCheck(
          halfLifeDays: halfLife,
          threshold: threshold,
          decayCurveType: decayCurve,
        );
        await NotificationService.instance.scheduleWeeklyDigest(
          halfLifeDays: halfLife,
          decayCurveType: decayCurve,
        );
      }
    } catch (e, stack) {
      debugPrint('Error scheduling notifications: $e\n$stack');
    }
  }

  @override
  void dispose() {
    ShareIntentService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const LinkShelfApp();
  }
}
