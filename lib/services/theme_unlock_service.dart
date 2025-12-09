import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_theme_model.dart';

/// Tema servisi - Tüm temalar ücretsiz!
class ThemeUnlockService {
  static const String _themeBoxName = 'unlocked_themes';
  static const String _selectedThemeKey = 'selected_theme';

  late Box<String> _themeBox;
  bool _initialized = false;

  /// Servisi başlat
  Future<void> init() async {
    if (_initialized) return;
    _themeBox = await Hive.openBox<String>(_themeBoxName);
    _initialized = true;
  }

  /// Tüm temaları al - Tüm temalar ücretsiz ve açık!
  List<AppThemeModel> getAllThemes() {
    return AppThemes.allThemes.map((theme) {
      return theme.copyWith(unlocked: true);
    }).toList();
  }

  /// Seçili temayı kaydet
  Future<void> setSelectedTheme(String themeId) async {
    await _themeBox.put(_selectedThemeKey, themeId);
  }

  /// Seçili tema ID'sini al
  String getSelectedThemeId() {
    return _themeBox.get(_selectedThemeKey, defaultValue: 'default')!;
  }

  /// Seçili temayı al
  AppThemeModel getSelectedTheme() {
    final themeId = getSelectedThemeId();
    final themes = getAllThemes();
    
    return themes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => themes.first,
    );
  }

  /// Tema istatistikleri
  ThemeStats getStats() {
    final themes = getAllThemes();
    return ThemeStats(
      total: themes.length,
      unlocked: themes.length, // Tüm temalar açık!
    );
  }
}

/// Tema istatistikleri
class ThemeStats {
  final int total;
  final int unlocked;

  const ThemeStats({required this.total, required this.unlocked});

  double get completionPercentage => total > 0 ? (unlocked / total * 100) : 0;
}
