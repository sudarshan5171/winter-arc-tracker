import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations & transparent status bar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive offline storage
  await StorageService.init();

  // Initialize Local Notifications
  await NotificationService.init();

  // Background silent Firebase Auth and sync (non-blocking, best-effort)
  SyncService.initSilently();

  runApp(
    const ProviderScope(
      child: WinterArcApp(),
    ),
  );
}

class WinterArcApp extends ConsumerWidget {
  const WinterArcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Winter Arc Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
