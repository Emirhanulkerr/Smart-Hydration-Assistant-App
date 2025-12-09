import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema kilit açma durumu
enum ThemeUnlockCondition {
  firstGoal,      // İlk hedef tamamlama
  streak7Days,    // 7 günlük seri
  streak14Days,   // 14 günlük seri (Hidrasyon Ustası)
  default_,       // Varsayılan (her zaman açık)
}

/// Uygulama tema modeli
class AppThemeModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool unlocked;
  final DateTime? unlockedAt;
  final ThemeUnlockCondition unlockCondition;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const AppThemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.unlocked,
    this.unlockedAt,
    required this.unlockCondition,
    required this.lightTheme,
    required this.darkTheme,
  });

  AppThemeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    bool? unlocked,
    DateTime? unlockedAt,
    ThemeUnlockCondition? unlockCondition,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return AppThemeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }

  AppThemeModel unlock() {
    return copyWith(
      unlocked: true,
      unlockedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, unlocked, unlockedAt, unlockCondition];
}

/// Tüm uygulama temaları
class AppThemes {
  AppThemes._();

  // ==================== RENK PALETLERİ ====================

  // Varsayılan - Calm Blue
  static const _defaultPrimary = Color(0xFF5DADE2);
  static const _defaultSecondary = Color(0xFF88D8B0);
  static const _defaultSurface = Color(0xFFF8FBFD);

  // Deniz Sessizliği - Sea Serenity
  static const _seaPrimary = Color(0xFF26A69A);
  static const _seaSecondary = Color(0xFF80CBC4);
  static const _seaTertiary = Color(0xFFB2DFDB);
  static const _seaSurface = Color(0xFFF0FDFA);
  static const _seaSurfaceDark = Color(0xFF1A2F2D);

  // Orman Sabahı - Forest Morning
  static const _forestPrimary = Color(0xFF66BB6A);
  static const _forestSecondary = Color(0xFFA5D6A7);
  static const _forestTertiary = Color(0xFFDCEDC8);
  static const _forestAccent = Color(0xFF8D6E63);
  static const _forestSurface = Color(0xFFF1F8E9);
  static const _forestSurfaceDark = Color(0xFF1B2A1B);

  // Gökyüzü Blues - Sky Blues
  static const _skyPrimary = Color(0xFF64B5F6);
  static const _skySecondary = Color(0xFF90CAF9);
  static const _skyTertiary = Color(0xFFBBDEFB);
  static const _skyAccent = Color(0xFFB0BEC5);
  static const _skySurface = Color(0xFFF5F9FF);
  static const _skySurfaceDark = Color(0xFF1A2533);

  // ==================== TEMA VERİLERİ ====================

  /// Varsayılan Tema (Calm Blue) - Her zaman açık
  static final defaultTheme = AppThemeModel(
    id: 'default',
    name: 'Sakin Mavi',
    description: 'Varsayılan sakin ve huzurlu tema',
    emoji: '💧',
    unlocked: true,
    unlockCondition: ThemeUnlockCondition.default_,
    lightTheme: _buildLightTheme(
      primary: _defaultPrimary,
      secondary: _defaultSecondary,
      surface: _defaultSurface,
    ),
    darkTheme: _buildDarkTheme(
      primary: _defaultPrimary,
      secondary: _defaultSecondary,
    ),
  );

  /// Deniz Sessizliği - Ücretsiz tema
  static final seaSerenityTheme = AppThemeModel(
    id: 'sea_serenity',
    name: 'Deniz Sessizliği',
    description: 'Turkuaz dalgaların sakinliği',
    emoji: '🌊',
    unlocked: true,
    unlockCondition: ThemeUnlockCondition.default_,
    lightTheme: _buildLightTheme(
      primary: _seaPrimary,
      secondary: _seaSecondary,
      tertiary: _seaTertiary,
      surface: _seaSurface,
    ),
    darkTheme: _buildDarkTheme(
      primary: _seaPrimary,
      secondary: _seaSecondary,
      surfaceDark: _seaSurfaceDark,
    ),
  );

  /// Orman Sabahı - Ücretsiz tema
  static final forestMorningTheme = AppThemeModel(
    id: 'forest_morning',
    name: 'Orman Sabahı',
    description: 'Doğanın ferahlığı ve tazeliği',
    emoji: '🌲',
    unlocked: true,
    unlockCondition: ThemeUnlockCondition.default_,
    lightTheme: _buildLightTheme(
      primary: _forestPrimary,
      secondary: _forestSecondary,
      tertiary: _forestTertiary,
      surface: _forestSurface,
      accent: _forestAccent,
    ),
    darkTheme: _buildDarkTheme(
      primary: _forestPrimary,
      secondary: _forestSecondary,
      surfaceDark: _forestSurfaceDark,
    ),
  );

  /// Gökyüzü Blues - Ücretsiz tema
  static final skyBluesTheme = AppThemeModel(
    id: 'sky_blues',
    name: 'Gökyüzü Blues',
    description: 'Açık gökyüzünün huzuru',
    emoji: '☁️',
    unlocked: true,
    unlockCondition: ThemeUnlockCondition.default_,
    lightTheme: _buildLightTheme(
      primary: _skyPrimary,
      secondary: _skySecondary,
      tertiary: _skyTertiary,
      surface: _skySurface,
      accent: _skyAccent,
    ),
    darkTheme: _buildDarkTheme(
      primary: _skyPrimary,
      secondary: _skySecondary,
      surfaceDark: _skySurfaceDark,
    ),
  );

  /// Tüm temalar
  static List<AppThemeModel> get allThemes => [
        defaultTheme,
        seaSerenityTheme,
        forestMorningTheme,
        skyBluesTheme,
      ];

  // ==================== TEMA OLUŞTURUCULAR ====================

  static ThemeData _buildLightTheme({
    required Color primary,
    required Color secondary,
    Color? tertiary,
    required Color surface,
    Color? accent,
  }) {
    final textPrimary = Color(0xFF2C3E50);
    final textSecondary = Color(0xFF7F8C8D);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primary.withValues(alpha: 0.2),
        secondary: secondary,
        secondaryContainer: secondary.withValues(alpha: 0.2),
        tertiary: tertiary ?? secondary.withValues(alpha: 0.5),
        surface: Colors.white,
        error: const Color(0xFFF39C12),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tertiary?.withValues(alpha: 0.3) ?? surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.2),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
        trackHeight: 6,
      ),
    );
  }

  static ThemeData _buildDarkTheme({
    required Color primary,
    required Color secondary,
    Color? surfaceDark,
  }) {
    final bgDark = surfaceDark ?? const Color(0xFF1A2634);
    final surfaceColor = Color.lerp(bgDark, Colors.white, 0.05)!;
    final textPrimary = const Color(0xFFECF0F1);
    final textSecondary = const Color(0xFFBDC3C7);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        primaryContainer: primary.withValues(alpha: 0.3),
        secondary: secondary,
        secondaryContainer: secondary.withValues(alpha: 0.3),
        surface: surfaceColor,
        error: const Color(0xFFF39C12),
        onPrimary: bgDark,
        onSecondary: bgDark,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgDark,
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: bgDark,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: bgDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.3),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
        trackHeight: 6,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.quicksand(fontSize: 57, fontWeight: FontWeight.w300, color: primary),
      displayMedium: GoogleFonts.quicksand(fontSize: 45, fontWeight: FontWeight.w400, color: primary),
      displaySmall: GoogleFonts.quicksand(fontSize: 36, fontWeight: FontWeight.w400, color: primary),
      headlineLarge: GoogleFonts.quicksand(fontSize: 32, fontWeight: FontWeight.w600, color: primary),
      headlineMedium: GoogleFonts.quicksand(fontSize: 28, fontWeight: FontWeight.w500, color: primary),
      headlineSmall: GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.w500, color: primary),
      titleLarge: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
      titleMedium: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w400, color: primary),
      bodySmall: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
    );
  }
}

