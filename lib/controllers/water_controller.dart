import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_entry.dart';
import '../models/user_settings.dart';
import '../models/daily_stats.dart';
import '../models/health_tip.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/health_tip_service.dart';
import '../services/streak_service.dart';
import '../services/achievement_service.dart';

/// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Health Tip Service Provider
final healthTipServiceProvider = Provider<HealthTipService>((ref) {
  return HealthTipService();
});

/// Streak Service Provider
final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

/// Achievement Service Provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// User Settings Provider
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UserSettingsNotifier(storageService);
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final StorageService _storageService;

  UserSettingsNotifier(this._storageService) : super(const UserSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = _storageService.getSettings();
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = settings;
    await _storageService.saveSettings(settings);
  }

  Future<void> setDailyGoal(int goal) async {
    await updateSettings(state.copyWith(dailyGoal: goal));
  }

  Future<void> setWeight(int weight) async {
    await updateSettings(state.copyWith(weight: weight));
  }

  Future<void> setTheme(String theme) async {
    await updateSettings(state.copyWith(selectedTheme: theme));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await updateSettings(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setNotificationInterval(int minutes) async {
    await updateSettings(state.copyWith(notificationIntervalMinutes: minutes));
  }

  Future<void> setDefaultCupSize(int size) async {
    await updateSettings(state.copyWith(defaultCupSize: size));
  }

  Future<void> setCupIcon(String icon) async {
    await updateSettings(state.copyWith(selectedCupIcon: icon));
  }

  Future<void> setUserName(String name) async {
    await updateSettings(state.copyWith(userName: name));
  }

  Future<void> setWakeUpHour(int hour) async {
    await updateSettings(state.copyWith(wakeUpHour: hour));
  }

  Future<void> setSleepHour(int hour) async {
    await updateSettings(state.copyWith(sleepHour: hour));
  }

  Future<void> completeOnboarding() async {
    await updateSettings(state.copyWith(onboardingCompleted: true));
  }

  Future<void> setColorIndex(int index) async {
    await updateSettings(state.copyWith(selectedColorIndex: index));
  }
}

/// Water Entries Provider - Bugünün su girdileri
final todayWaterEntriesProvider = StateNotifierProvider<WaterEntriesNotifier, List<WaterEntry>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final settings = ref.watch(userSettingsProvider);
  return WaterEntriesNotifier(storageService, settings, ref);
});

class WaterEntriesNotifier extends StateNotifier<List<WaterEntry>> {
  final StorageService _storageService;
  final UserSettings _settings;
  final Ref _ref;

  WaterEntriesNotifier(this._storageService, this._settings, this._ref) : super([]) {
    _loadTodayEntries();
  }

  void _loadTodayEntries() {
    state = _storageService.getWaterEntriesForDate(DateTime.now());
  }

  /// Yeni su girdisi ekle
  Future<void> addWaterEntry(int amount, {String? note}) async {
    final entry = WaterEntry.create(amount: amount, note: note);
    await _storageService.addWaterEntry(entry);
    state = [entry, ...state];

    // Günlük istatistikleri güncelle
    await _updateDailyStats();

    // Hedefe ulaşıldı mı kontrol et
    final totalToday = state.fold(0, (sum, e) => sum + e.amount);
    if (totalToday >= _settings.dailyGoal) {
      // İlk kez hedefe ulaşıldıysa bildirim göster
      final previousTotal = totalToday - amount;
      if (previousTotal < _settings.dailyGoal) {
        final notificationService = _ref.read(notificationServiceProvider);
        await notificationService.showGoalReachedNotification();
      }
    }

    // Streak güncelle
    _ref.read(streakStatusProvider.notifier).updateStreak(
      dailyIntake: totalToday.toDouble(),
      dailyGoal: _settings.dailyGoal.toDouble(),
    );

    // Başarımları kontrol et
    _ref.read(achievementsControllerProvider.notifier).checkAchievements();
  }

  /// Su girdisi sil
  Future<void> deleteWaterEntry(String id) async {
    await _storageService.deleteWaterEntry(id);
    state = state.where((entry) => entry.id != id).toList();
    await _updateDailyStats();
  }

  /// Günlük istatistikleri güncelle
  Future<void> _updateDailyStats() async {
    final today = DateTime.now();
    final totalAmount = state.fold(0, (sum, entry) => sum + entry.amount);
    final goalReached = totalAmount >= _settings.dailyGoal;

    final stats = DailyStats(
      date: DateTime(today.year, today.month, today.day),
      totalAmount: totalAmount,
      goal: _settings.dailyGoal,
      entryCount: state.length,
      goalReached: goalReached,
    );

    await _storageService.saveDailyStats(stats);
  }

  /// Girdileri yenile
  void refresh() {
    _loadTodayEntries();
  }
}

/// Bugünkü toplam su miktarı
final todayTotalWaterProvider = Provider<int>((ref) {
  final entries = ref.watch(todayWaterEntriesProvider);
  return entries.fold(0, (sum, entry) => sum + entry.amount);
});

/// Bugünkü ilerleme yüzdesi
final todayProgressProvider = Provider<double>((ref) {
  final total = ref.watch(todayTotalWaterProvider);
  final settings = ref.watch(userSettingsProvider);
  return (total / settings.dailyGoal * 100).clamp(0.0, 100.0);
});

/// Hedefe ulaşıldı mı
final goalReachedProvider = Provider<bool>((ref) {
  final progress = ref.watch(todayProgressProvider);
  return progress >= 100;
});

/// Mevcut seri (eski provider - uyumluluk için)
final currentStreakProvider = Provider<int>((ref) {
  final streakStatus = ref.watch(streakStatusProvider);
  return streakStatus.currentStreak;
});

/// Streak Status Provider - Gelişmiş streak takibi
final streakStatusProvider = StateNotifierProvider<StreakStatusNotifier, StreakStatus>((ref) {
  final streakService = ref.watch(streakServiceProvider);
  return StreakStatusNotifier(streakService);
});

class StreakStatusNotifier extends StateNotifier<StreakStatus> {
  final StreakService _streakService;

  StreakStatusNotifier(this._streakService) : super(const StreakStatus()) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    await _streakService.init();
    state = _streakService.getStreakStatus();
  }

  Future<StreakUpdateResult?> updateStreak({
    required double dailyIntake,
    required double dailyGoal,
  }) async {
    final result = await _streakService.updateStreak(
      dailyIntake: dailyIntake,
      dailyGoal: dailyGoal,
    );
    state = result.status;
    return result;
  }

  void refresh() {
    state = _streakService.getStreakStatus();
  }
}

/// Health Tip Provider - Kişiselleştirilmiş sağlık önerileri
final currentHealthTipProvider = Provider<HealthTip>((ref) {
  final healthTipService = ref.watch(healthTipServiceProvider);
  final progress = ref.watch(todayProgressProvider);
  final total = ref.watch(todayTotalWaterProvider);
  final settings = ref.watch(userSettingsProvider);
  final streakStatus = ref.watch(streakStatusProvider);

  return healthTipService.generateTip(
    dailyIntake: total.toDouble(),
    dailyGoal: settings.dailyGoal.toDouble(),
    streak: streakStatus.currentStreak,
    progressPercentage: progress,
  );
});

/// Streak bazlı health tip
final streakHealthTipProvider = Provider<HealthTip>((ref) {
  final healthTipService = ref.watch(healthTipServiceProvider);
  final streakStatus = ref.watch(streakStatusProvider);

  return healthTipService.getStreakTip(
    streakStatus.currentStreak,
    streakStatus.isAtRisk,
  );
});

/// İstatistikler Provider
final statsProvider = Provider.family<List<DailyStats>, DateRange>((ref, range) {
  final storageService = ref.watch(storageServiceProvider);
  return storageService.getDailyStatsInRange(range.start, range.end);
});

/// Tarih aralığı için helper class
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  /// Son 7 gün
  factory DateRange.lastWeek() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  /// Son 30 gün
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 29)),
      end: now,
    );
  }

  /// Bu ay
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }
}

/// Başarılar Controller Provider
final achievementsControllerProvider = StateNotifierProvider<AchievementsController, AchievementsState>((ref) {
  final achievementService = ref.watch(achievementServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AchievementsController(achievementService, storageService, ref);
});

class AchievementsState {
  final List<Achievement> achievements;
  final List<Achievement> recentlyUnlocked;
  final AchievementStats stats;
  final bool isLoading;

  const AchievementsState({
    this.achievements = const [],
    this.recentlyUnlocked = const [],
    this.stats = const AchievementStats(total: 0, unlocked: 0, completionPercentage: 0),
    this.isLoading = false,
  });

  AchievementsState copyWith({
    List<Achievement>? achievements,
    List<Achievement>? recentlyUnlocked,
    AchievementStats? stats,
    bool? isLoading,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AchievementsController extends StateNotifier<AchievementsState> {
  final AchievementService _achievementService;
  final StorageService _storageService;
  final Ref _ref;

  AchievementsController(this._achievementService, this._storageService, this._ref) 
      : super(const AchievementsState()) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    state = state.copyWith(isLoading: true);
    await _achievementService.init();
    
    final achievements = _achievementService.getAllAchievements();
    final stats = _achievementService.getStats();
    
    state = AchievementsState(
      achievements: achievements,
      stats: stats,
      isLoading: false,
    );
  }

  Future<void> checkAchievements() async {
    final streakStatus = _ref.read(streakStatusProvider);
    final totalToday = _ref.read(todayTotalWaterProvider);
    final progress = _ref.read(todayProgressProvider);
    final entries = _ref.read(todayWaterEntriesProvider);

    // Toplam içilen suyu hesapla
    final totalIntake = _storageService.getTotalWaterEver() + totalToday;

    // Art arda hedef tamamlama sayısı
    final consecutiveGoals = _calculateConsecutiveGoals();

    final unlockedNow = await _achievementService.checkAndUnlockAchievements(
      currentStreak: streakStatus.currentStreak,
      bestStreak: streakStatus.bestStreak,
      totalIntake: totalIntake,
      todayProgress: progress,
      todayEntryCount: entries.length,
      consecutiveGoals: consecutiveGoals,
    );

    if (unlockedNow.isNotEmpty) {
      state = state.copyWith(
        achievements: _achievementService.getAllAchievements(),
        recentlyUnlocked: unlockedNow,
        stats: _achievementService.getStats(),
      );
    }
  }

  int _calculateConsecutiveGoals() {
    final stats = _storageService.getDailyStatsInRange(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );
    
    int consecutive = 0;
    for (final stat in stats.reversed) {
      if (stat.goalReached) {
        consecutive++;
      } else {
        break;
      }
    }
    return consecutive;
  }

  void clearRecentlyUnlocked() {
    state = state.copyWith(recentlyUnlocked: []);
  }

  void refresh() {
    _loadAchievements();
  }

  Map<String, List<Achievement>> getAchievementsByCategory() {
    return _achievementService.getAchievementsByCategory();
  }
}

/// Eski başarılar provider - geriye uyumluluk için
final achievementsProvider = StateNotifierProvider<AchievementsNotifier, List<Achievement>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AchievementsNotifier(storageService);
});

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  final StorageService _storageService;

  AchievementsNotifier(this._storageService) : super([]) {
    _loadAchievements();
  }

  void _loadAchievements() {
    state = _storageService.getAchievements();
  }

  Future<Achievement?> checkAndUnlockAchievement(String id) async {
    final unlocked = await _storageService.unlockAchievement(id);
    if (unlocked != null) {
      state = state.map((a) => a.id == id ? unlocked : a).toList();
    }
    return unlocked;
  }

  void refresh() {
    _loadAchievements();
  }
}
