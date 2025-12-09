import 'package:hive_flutter/hive_flutter.dart';
import '../models/badge_model.dart';

/// Rozet (Badge) servisi
class BadgeService {
  static const String _badgeBoxName = 'badges_v3';

  late Box<Badge> _badgeBox;
  bool _initialized = false;

  /// Servisi başlat
  Future<void> init() async {
    if (_initialized) return;

    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(BadgeAdapter());
    }

    _badgeBox = await Hive.openBox<Badge>(_badgeBoxName);

    // İlk kez açılıyorsa rozetleri ekle
    if (_badgeBox.isEmpty) {
      for (final badge in Badges.allBadges) {
        await _badgeBox.put(badge.id, badge);
      }
    }

    _initialized = true;
  }

  /// Tüm rozetleri al
  List<Badge> getAllBadges() {
    if (_badgeBox.isEmpty) {
      return Badges.allBadges;
    }
    return _badgeBox.values.toList()
      ..sort((a, b) => a.streakRequired.compareTo(b.streakRequired));
  }

  /// Kilidi açık rozetleri al
  List<Badge> getUnlockedBadges() {
    return getAllBadges().where((b) => b.unlocked).toList();
  }

  /// Kilitli rozetleri al
  List<Badge> getLockedBadges() {
    return getAllBadges().where((b) => !b.unlocked).toList();
  }

  /// Belirli bir rozeti al
  Badge? getBadge(String id) {
    return _badgeBox.get(id);
  }

  /// Rozet kilidini aç
  Future<Badge?> unlockBadge(String id) async {
    final badge = _badgeBox.get(id);
    if (badge != null && !badge.unlocked) {
      final unlocked = badge.unlock();
      await _badgeBox.put(id, unlocked);
      return unlocked;
    }
    return null;
  }

  /// Streak'e göre rozetleri kontrol et ve kilidi aç
  Future<List<Badge>> checkAndUnlockBadges(int currentStreak) async {
    final unlockedNow = <Badge>[];

    for (final badge in getAllBadges()) {
      if (!badge.unlocked && currentStreak >= badge.streakRequired) {
        final unlocked = await unlockBadge(badge.id);
        if (unlocked != null) {
          unlockedNow.add(unlocked);
        }
      }
    }

    return unlockedNow;
  }

  /// Sonraki açılacak rozeti al
  Badge? getNextBadgeToUnlock(int currentStreak) {
    final locked = getLockedBadges();
    if (locked.isEmpty) return null;

    // En yakın hedefe sahip rozeti bul
    locked.sort((a, b) => a.streakRequired.compareTo(b.streakRequired));
    return locked.first;
  }

  /// Sonraki rozete kalan gün sayısı
  int getDaysUntilNextBadge(int currentStreak) {
    final nextBadge = getNextBadgeToUnlock(currentStreak);
    if (nextBadge == null) return 0;
    return nextBadge.streakRequired - currentStreak;
  }

  /// Rozet istatistikleri
  BadgeStats getStats() {
    final all = getAllBadges();
    final unlocked = all.where((b) => b.unlocked).length;
    return BadgeStats(
      total: all.length,
      unlocked: unlocked,
    );
  }

  /// En son açılan rozeti al
  Badge? getLastUnlockedBadge() {
    final unlocked = getUnlockedBadges();
    if (unlocked.isEmpty) return null;

    unlocked.sort((a, b) {
      final aDate = a.unlockedAt ?? DateTime(1970);
      final bDate = b.unlockedAt ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });

    return unlocked.first;
  }

  /// Rozet ilerlemesi (yüzde)
  double getProgressToNextBadge(int currentStreak) {
    final nextBadge = getNextBadgeToUnlock(currentStreak);
    if (nextBadge == null) return 100;

    final previousBadge = getUnlockedBadges().lastOrNull;
    final startStreak = previousBadge?.streakRequired ?? 0;
    final targetStreak = nextBadge.streakRequired;
    
    final progress = (currentStreak - startStreak) / (targetStreak - startStreak) * 100;
    return progress.clamp(0, 100);
  }
}

/// Rozet istatistikleri
class BadgeStats {
  final int total;
  final int unlocked;

  const BadgeStats({required this.total, required this.unlocked});

  double get completionPercentage => total > 0 ? (unlocked / total * 100) : 0;
}

