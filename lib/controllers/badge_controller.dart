import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';

/// Badge Service Provider
final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService();
});

/// Badge Controller State
class BadgeState {
  final List<Badge> badges;
  final BadgeStats stats;
  final Badge? nextBadge;
  final double progressToNext;
  final int daysUntilNext;
  final List<Badge> recentlyUnlocked;
  final bool isLoading;

  const BadgeState({
    this.badges = const [],
    this.stats = const BadgeStats(total: 0, unlocked: 0),
    this.nextBadge,
    this.progressToNext = 0,
    this.daysUntilNext = 0,
    this.recentlyUnlocked = const [],
    this.isLoading = false,
  });

  BadgeState copyWith({
    List<Badge>? badges,
    BadgeStats? stats,
    Badge? nextBadge,
    double? progressToNext,
    int? daysUntilNext,
    List<Badge>? recentlyUnlocked,
    bool? isLoading,
  }) {
    return BadgeState(
      badges: badges ?? this.badges,
      stats: stats ?? this.stats,
      nextBadge: nextBadge ?? this.nextBadge,
      progressToNext: progressToNext ?? this.progressToNext,
      daysUntilNext: daysUntilNext ?? this.daysUntilNext,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Badge Controller Provider
final badgeControllerProvider =
    StateNotifierProvider<BadgeController, BadgeState>((ref) {
  final badgeService = ref.watch(badgeServiceProvider);
  return BadgeController(badgeService);
});

class BadgeController extends StateNotifier<BadgeState> {
  final BadgeService _badgeService;

  BadgeController(this._badgeService) : super(const BadgeState()) {
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    state = state.copyWith(isLoading: true);
    await _badgeService.init();

    _refreshState(0);
  }

  void _refreshState(int currentStreak) {
    final badges = _badgeService.getAllBadges();
    final stats = _badgeService.getStats();
    final nextBadge = _badgeService.getNextBadgeToUnlock(currentStreak);
    final progressToNext = _badgeService.getProgressToNextBadge(currentStreak);
    final daysUntilNext = _badgeService.getDaysUntilNextBadge(currentStreak);

    state = BadgeState(
      badges: badges,
      stats: stats,
      nextBadge: nextBadge,
      progressToNext: progressToNext,
      daysUntilNext: daysUntilNext,
      isLoading: false,
    );
  }

  /// Streak değiştiğinde rozetleri kontrol et
  Future<List<Badge>> checkBadges(int currentStreak) async {
    final unlockedNow = await _badgeService.checkAndUnlockBadges(currentStreak);

    if (unlockedNow.isNotEmpty) {
      _refreshState(currentStreak);
      state = state.copyWith(recentlyUnlocked: unlockedNow);
    } else {
      // Sadece ilerlemeyi güncelle
      final nextBadge = _badgeService.getNextBadgeToUnlock(currentStreak);
      final progressToNext = _badgeService.getProgressToNextBadge(currentStreak);
      final daysUntilNext = _badgeService.getDaysUntilNextBadge(currentStreak);

      state = state.copyWith(
        nextBadge: nextBadge,
        progressToNext: progressToNext,
        daysUntilNext: daysUntilNext,
      );
    }

    return unlockedNow;
  }

  /// Son açılan rozetleri temizle
  void clearRecentlyUnlocked() {
    state = state.copyWith(recentlyUnlocked: []);
  }

  /// Manuel yenileme
  void refresh(int currentStreak) {
    _refreshState(currentStreak);
  }

  /// Belirli bir rozeti al
  Badge? getBadge(String id) {
    return _badgeService.getBadge(id);
  }

  /// Son açılan rozeti al
  Badge? getLastUnlockedBadge() {
    return _badgeService.getLastUnlockedBadge();
  }
}

/// Kilidi açık rozetler provider
final unlockedBadgesProvider = Provider<List<Badge>>((ref) {
  final badgeState = ref.watch(badgeControllerProvider);
  return badgeState.badges.where((b) => b.unlocked).toList();
});

/// Sonraki rozet provider
final nextBadgeProvider = Provider<Badge?>((ref) {
  final badgeState = ref.watch(badgeControllerProvider);
  return badgeState.nextBadge;
});

