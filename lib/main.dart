import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/water_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/badge_controller.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/streak_service.dart';
import 'services/achievement_service.dart';
import 'services/theme_unlock_service.dart';
import 'services/badge_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Türkçe tarih formatı için
  await initializeDateFormatting('tr_TR', null);
  
  // Storage servisini başlat
  final storageService = StorageService();
  await storageService.init();
  
  // Notification servisini başlat
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Streak servisini başlat
  final streakService = StreakService();
  await streakService.init();
  
  // Achievement servisini başlat
  final achievementService = AchievementService();
  await achievementService.init();
  
  // Theme Unlock servisini başlat
  final themeUnlockService = ThemeUnlockService();
  await themeUnlockService.init();
  
  // Badge servisini başlat
  final badgeService = BadgeService();
  await badgeService.init();
  
  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Ekran yönünü kilitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        notificationServiceProvider.overrideWithValue(notificationService),
        streakServiceProvider.overrideWithValue(streakService),
        achievementServiceProvider.overrideWithValue(achievementService),
        themeUnlockServiceProvider.overrideWithValue(themeUnlockService),
        badgeServiceProvider.overrideWithValue(badgeService),
      ],
      child: const HydrationApp(),
    ),
  );
}

class HydrationApp extends ConsumerWidget {
  const HydrationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final themeState = ref.watch(themeControllerProvider);
    
    // Tema modunu belirle
    ThemeMode themeMode;
    switch (settings.selectedTheme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Hydration App',
      debugShowCheckedModeBanner: false,
      // Dinamik tema kullan
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeMode,
      home: settings.onboardingCompleted
          ? const MainShell()
          : const OnboardingScreen(),
    );
  }
}
