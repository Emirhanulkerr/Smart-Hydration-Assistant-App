import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme_model.dart';
import '../services/theme_unlock_service.dart';

/// Theme Service Provider
final themeUnlockServiceProvider = Provider<ThemeUnlockService>((ref) {
  return ThemeUnlockService();
});

/// Theme Controller State
class ThemeState {
  final List<AppThemeModel> themes;
  final String selectedThemeId;
  final ThemeStats stats;
  final bool isLoading;

  const ThemeState({
    this.themes = const [],
    this.selectedThemeId = 'default',
    this.stats = const ThemeStats(total: 0, unlocked: 0),
    this.isLoading = false,
  });

  ThemeState copyWith({
    List<AppThemeModel>? themes,
    String? selectedThemeId,
    ThemeStats? stats,
    bool? isLoading,
  }) {
    return ThemeState(
      themes: themes ?? this.themes,
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Seçili tema
  AppThemeModel get selectedTheme {
    return themes.firstWhere(
      (t) => t.id == selectedThemeId,
      orElse: () => themes.isNotEmpty ? themes.first : AppThemes.defaultTheme,
    );
  }

  /// Light tema verisi
  ThemeData get lightTheme => selectedTheme.lightTheme;

  /// Dark tema verisi
  ThemeData get darkTheme => selectedTheme.darkTheme;
}

/// Theme Controller Provider
final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeState>((ref) {
  final themeService = ref.watch(themeUnlockServiceProvider);
  return ThemeController(themeService);
});

class ThemeController extends StateNotifier<ThemeState> {
  final ThemeUnlockService _themeService;

  ThemeController(this._themeService) : super(const ThemeState()) {
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    state = state.copyWith(isLoading: true);
    await _themeService.init();

    final themes = _themeService.getAllThemes();
    final selectedId = _themeService.getSelectedThemeId();
    final stats = _themeService.getStats();

    state = ThemeState(
      themes: themes,
      selectedThemeId: selectedId,
      stats: stats,
      isLoading: false,
    );
  }

  /// Tema seç
  Future<void> selectTheme(String themeId) async {
    await _themeService.setSelectedTheme(themeId);
    state = state.copyWith(selectedThemeId: themeId);
  }

  /// Manuel yenileme
  void refresh() {
    _loadThemes();
  }
}

/// Seçili light theme provider
final selectedLightThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeControllerProvider);
  return themeState.lightTheme;
});

/// Seçili dark theme provider
final selectedDarkThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeControllerProvider);
  return themeState.darkTheme;
});
