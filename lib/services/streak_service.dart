import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_tip.dart';

/// Streak yönetim servisi - Soft reset mekanizması ile
class StreakService {
  static const String _streakBoxName = 'streak_data';
  static const String _currentStreakKey = 'current_streak';
  static const String _bestStreakKey = 'best_streak';
  static const String _forgivenessDaysKey = 'forgiveness_days';
  static const String _lastUpdateKey = 'last_update';
  static const String _recentProgressKey = 'recent_progress';
  static const String _consecutiveLowDaysKey = 'consecutive_low_days';

  late Box _streakBox;
  bool _initialized = false;

  /// Servisi başlat
  Future<void> init() async {
    if (_initialized) return;
    _streakBox = await Hive.openBox(_streakBoxName);
    _initialized = true;
  }

  /// Mevcut streak durumunu al
  StreakStatus getStreakStatus() {
    return StreakStatus(
      currentStreak: _streakBox.get(_currentStreakKey, defaultValue: 0),
      bestStreak: _streakBox.get(_bestStreakKey, defaultValue: 0),
      forgivenessDaysLeft: _streakBox.get(_forgivenessDaysKey, defaultValue: 1),
      lastUpdateDate: _streakBox.get(_lastUpdateKey) != null
          ? DateTime.parse(_streakBox.get(_lastUpdateKey))
          : null,
      recentProgress: List<double>.from(
        _streakBox.get(_recentProgressKey, defaultValue: <double>[]),
      ),
    );
  }

  /// Günlük streak güncelleme - Soft reset mekanizması
  /// 
  /// Kurallar:
  /// - %70+ ilerleme = Streak devam eder
  /// - %50-69 ilerleme = Affetme günü kullanılır (varsa)
  /// - %50 altı 2 gün art arda = Streak sıfırlanır
  Future<StreakUpdateResult> updateStreak({
    required double dailyIntake,
    required double dailyGoal,
  }) async {
    final progressPercentage = (dailyIntake / dailyGoal * 100).clamp(0.0, 100.0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastUpdate = _streakBox.get(_lastUpdateKey);
    final lastUpdateDate = lastUpdate != null 
        ? DateTime.parse(lastUpdate) 
        : null;
    
    // Bugün zaten güncellendi mi kontrol et
    if (lastUpdateDate != null) {
      final lastDate = DateTime(lastUpdateDate.year, lastUpdateDate.month, lastUpdateDate.day);
      if (lastDate == today) {
        // Bugün zaten güncellendi, sadece ilerlemeyi güncelle
        await _updateRecentProgress(progressPercentage);
        return StreakUpdateResult(
          status: getStreakStatus(),
          action: StreakAction.alreadyUpdated,
          message: null,
        );
      }
    }

    int currentStreak = _streakBox.get(_currentStreakKey, defaultValue: 0);
    int bestStreak = _streakBox.get(_bestStreakKey, defaultValue: 0);
    int forgivenessDays = _streakBox.get(_forgivenessDaysKey, defaultValue: 1);
    int consecutiveLowDays = _streakBox.get(_consecutiveLowDaysKey, defaultValue: 0);

    StreakAction action;
    String? message;

    if (progressPercentage >= 70) {
      // Başarılı gün - Streak devam eder
      currentStreak++;
      consecutiveLowDays = 0;
      
      // Her 7 günde bir affetme hakkı yenile
      if (currentStreak % 7 == 0 && forgivenessDays < 2) {
        forgivenessDays++;
        message = 'Tebrikler! Bir affetme günü kazandın 🎁';
      }
      
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
        action = StreakAction.newRecord;
        message ??= 'Yeni rekor! $bestStreak gün 🏆';
      } else {
        action = StreakAction.continued;
      }
    } else if (progressPercentage >= 50) {
      // Orta performans - Affetme günü kullan
      if (forgivenessDays > 0) {
        forgivenessDays--;
        currentStreak++; // Streak devam eder
        consecutiveLowDays = 0;
        action = StreakAction.forgiven;
        message = 'Affetme günü kullanıldı. Streak devam ediyor! 💪';
      } else {
        // Affetme hakkı yok, streak tehlikede
        consecutiveLowDays++;
        if (consecutiveLowDays >= 2) {
          currentStreak = 0;
          consecutiveLowDays = 0;
          action = StreakAction.reset;
          message = 'Bugün yeniden başlamak için güzel bir gün. 🌱';
        } else {
          action = StreakAction.atRisk;
          message = 'Yarın %70 hedefine ulaşırsan streak devam eder!';
        }
      }
    } else {
      // Düşük performans
      consecutiveLowDays++;
      if (consecutiveLowDays >= 2) {
        currentStreak = 0;
        consecutiveLowDays = 0;
        action = StreakAction.reset;
        message = 'Yeni bir başlangıç için mükemmel gün! Her yolculuk tek adımla başlar. 🌱';
      } else {
        if (forgivenessDays > 0) {
          forgivenessDays--;
          action = StreakAction.forgiven;
          message = 'Affetme günü kullanıldı. Yarın daha iyi olacak! 💪';
        } else {
          action = StreakAction.atRisk;
          message = 'Streak risk altında. Yarın hedefin %70\'ine ulaşmayı dene!';
        }
      }
    }

    // Değerleri kaydet
    await _streakBox.put(_currentStreakKey, currentStreak);
    await _streakBox.put(_bestStreakKey, bestStreak);
    await _streakBox.put(_forgivenessDaysKey, forgivenessDays);
    await _streakBox.put(_lastUpdateKey, today.toIso8601String());
    await _streakBox.put(_consecutiveLowDaysKey, consecutiveLowDays);
    await _updateRecentProgress(progressPercentage);

    return StreakUpdateResult(
      status: StreakStatus(
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        forgivenessDaysLeft: forgivenessDays,
        isAtRisk: action == StreakAction.atRisk,
        lastUpdateDate: today,
        recentProgress: List<double>.from(
          _streakBox.get(_recentProgressKey, defaultValue: <double>[]),
        ),
      ),
      action: action,
      message: message,
    );
  }

  /// Son 7 günün ilerlemesini güncelle
  Future<void> _updateRecentProgress(double progress) async {
    List<double> recentProgress = List<double>.from(
      _streakBox.get(_recentProgressKey, defaultValue: <double>[]),
    );
    
    recentProgress.add(progress);
    
    // Sadece son 7 günü tut
    if (recentProgress.length > 7) {
      recentProgress = recentProgress.sublist(recentProgress.length - 7);
    }
    
    await _streakBox.put(_recentProgressKey, recentProgress);
  }

  /// Ortalama ilerleme hesapla
  double getAverageProgress() {
    final status = getStreakStatus();
    if (status.recentProgress.isEmpty) return 0;
    return status.recentProgress.reduce((a, b) => a + b) / status.recentProgress.length;
  }

  /// Streak verilerini sıfırla (test amaçlı)
  Future<void> resetStreak() async {
    await _streakBox.put(_currentStreakKey, 0);
    await _streakBox.put(_forgivenessDaysKey, 1);
    await _streakBox.put(_consecutiveLowDaysKey, 0);
    await _streakBox.put(_recentProgressKey, <double>[]);
  }
}

/// Streak güncelleme sonucu
class StreakUpdateResult {
  final StreakStatus status;
  final StreakAction action;
  final String? message;

  const StreakUpdateResult({
    required this.status,
    required this.action,
    this.message,
  });
}

/// Streak aksiyonu
enum StreakAction {
  continued,       // Streak devam etti
  newRecord,       // Yeni rekor kırıldı
  forgiven,        // Affetme günü kullanıldı
  atRisk,          // Streak risk altında
  reset,           // Streak sıfırlandı
  alreadyUpdated,  // Bugün zaten güncellendi
}

