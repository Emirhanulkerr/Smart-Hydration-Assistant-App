import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_stats.dart';

/// Genişletilmiş başarım servisi
class AchievementService {
  static const String _achievementBoxName = 'achievements_v2';
  static const String _progressBoxName = 'achievement_progress';

  late Box<Achievement> _achievementBox;
  late Box _progressBox;
  bool _initialized = false;

  /// Tüm başarımlar - Genişletilmiş liste
  static final List<Achievement> allAchievements = [
    // ===== Streak Başarımları =====
    const Achievement(
      id: 'streak_3',
      title: 'İlk Adımlar 🌱',
      description: '3 gün üst üste hedefine ulaş',
      icon: '🌱',
      requiredValue: 3,
      type: 'streak',
    ),
    const Achievement(
      id: 'streak_7',
      title: 'Haftalık Kahraman 🌟',
      description: '7 gün üst üste hedefine ulaş',
      icon: '🌟',
      requiredValue: 7,
      type: 'streak',
    ),
    const Achievement(
      id: 'streak_14',
      title: 'İki Haftalık Şampiyon 💪',
      description: '14 gün üst üste hedefine ulaş',
      icon: '💪',
      requiredValue: 14,
      type: 'streak',
    ),
    const Achievement(
      id: 'streak_30',
      title: 'Aylık Efsane 🏆',
      description: '30 gün üst üste hedefine ulaş',
      icon: '🏆',
      requiredValue: 30,
      type: 'streak',
    ),
    const Achievement(
      id: 'streak_100',
      title: 'Yüz Günlük Usta 👑',
      description: '100 gün üst üste hedefine ulaş',
      icon: '👑',
      requiredValue: 100,
      type: 'streak',
    ),

    // ===== Günlük Hedef Başarımları =====
    const Achievement(
      id: 'first_goal',
      title: 'İlk Zafer ✨',
      description: 'İlk kez günlük hedefini tamamla',
      icon: '✨',
      requiredValue: 1,
      type: 'daily_goal',
    ),
    const Achievement(
      id: 'goals_3_consecutive',
      title: 'Üçlü Kombo 🎯',
      description: 'Art arda 3 gün hedefini tamamla',
      icon: '🎯',
      requiredValue: 3,
      type: 'consecutive_goals',
    ),
    const Achievement(
      id: 'goals_exceed_120',
      title: 'Ekstra Hidrasyon 💦',
      description: 'Günlük hedefini %120 aş',
      icon: '💦',
      requiredValue: 120,
      type: 'daily_percentage',
    ),

    // ===== Toplam Su Başarımları =====
    const Achievement(
      id: 'total_10L',
      title: 'Su Çömezi 💧',
      description: 'Toplam 10 litre su iç',
      icon: '💧',
      requiredValue: 10000,
      type: 'total_intake',
    ),
    const Achievement(
      id: 'total_50L',
      title: 'Hidrasyon Ustası 🌊',
      description: 'Toplam 50 litre su iç',
      icon: '🌊',
      requiredValue: 50000,
      type: 'total_intake',
    ),
    const Achievement(
      id: 'total_100L',
      title: 'Su Efendisi 🎖️',
      description: 'Toplam 100 litre su iç',
      icon: '🎖️',
      requiredValue: 100000,
      type: 'total_intake',
    ),
    const Achievement(
      id: 'total_500L',
      title: 'Okyanus Kralı 🌏',
      description: 'Toplam 500 litre su iç',
      icon: '🌏',
      requiredValue: 500000,
      type: 'total_intake',
    ),

    // ===== Davranış Başarımları =====
    const Achievement(
      id: 'morning_habit',
      title: 'Erken Kuş 🌅',
      description: 'Sabah 9\'dan önce su iç (7 gün)',
      icon: '🌅',
      requiredValue: 7,
      type: 'morning_habit',
    ),
    const Achievement(
      id: 'evening_complete',
      title: 'Gece Yıldızı 🌙',
      description: 'Akşam 6\'dan sonra hedefi tamamla',
      icon: '🌙',
      requiredValue: 5,
      type: 'evening_habit',
    ),
    const Achievement(
      id: 'three_times_daily',
      title: 'Düzenli İçici 📊',
      description: 'Günde en az 3 kez su ekle (7 gün)',
      icon: '📊',
      requiredValue: 7,
      type: 'frequency_habit',
    ),
    const Achievement(
      id: 'weekend_warrior',
      title: 'Hafta Sonu Savaşçısı 🏅',
      description: 'Hafta sonları da hedefini tamamla (4 hafta sonu)',
      icon: '🏅',
      requiredValue: 4,
      type: 'weekend_habit',
    ),

    // ===== Özel Başarımlar =====
    const Achievement(
      id: 'comeback',
      title: 'Geri Dönüş 🔄',
      description: 'Streak kaybettikten sonra 7 günlük yeni seri başlat',
      icon: '🔄',
      requiredValue: 7,
      type: 'comeback',
    ),
    const Achievement(
      id: 'perfect_week',
      title: 'Mükemmel Hafta ⭐',
      description: 'Bir hafta boyunca her gün hedefe ulaş',
      icon: '⭐',
      requiredValue: 7,
      type: 'perfect_week',
    ),
    const Achievement(
      id: 'overachiever',
      title: 'Üstün Başarı 🚀',
      description: 'Hedefini %150 aş',
      icon: '🚀',
      requiredValue: 150,
      type: 'daily_percentage',
    ),
  ];

  /// Servisi başlat
  Future<void> init() async {
    if (_initialized) return;

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AchievementAdapter());
    }

    _achievementBox = await Hive.openBox<Achievement>(_achievementBoxName);
    _progressBox = await Hive.openBox(_progressBoxName);

    // İlk kez açılıyorsa başarımları ekle
    if (_achievementBox.isEmpty) {
      for (final achievement in allAchievements) {
        await _achievementBox.put(achievement.id, achievement);
      }
    } else {
      // Yeni eklenen başarımları kontrol et
      for (final achievement in allAchievements) {
        if (!_achievementBox.containsKey(achievement.id)) {
          await _achievementBox.put(achievement.id, achievement);
        }
      }
    }

    _initialized = true;
  }

  /// Tüm başarımları al
  List<Achievement> getAllAchievements() {
    return _achievementBox.values.toList();
  }

  /// Kilidi açılmış başarımları al
  List<Achievement> getUnlockedAchievements() {
    return _achievementBox.values.where((a) => a.isUnlocked).toList();
  }

  /// Kilidi açılmamış başarımları al
  List<Achievement> getLockedAchievements() {
    return _achievementBox.values.where((a) => !a.isUnlocked).toList();
  }

  /// Başarım ilerlemesini kontrol et ve kilidi aç
  Future<List<Achievement>> checkAndUnlockAchievements({
    required int currentStreak,
    required int bestStreak,
    required int totalIntake,
    required double todayProgress,
    required int todayEntryCount,
    required int consecutiveGoals,
    int? morningDrinkDays,
    int? eveningCompleteDays,
    int? frequencyDays,
    int? weekendGoalDays,
    bool? isComeback,
  }) async {
    final unlockedNow = <Achievement>[];

    for (final achievement in _achievementBox.values) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case 'streak':
          shouldUnlock = currentStreak >= achievement.requiredValue;
          break;
        case 'daily_goal':
          shouldUnlock = todayProgress >= 100;
          break;
        case 'consecutive_goals':
          shouldUnlock = consecutiveGoals >= achievement.requiredValue;
          break;
        case 'daily_percentage':
          shouldUnlock = todayProgress >= achievement.requiredValue;
          break;
        case 'total_intake':
          shouldUnlock = totalIntake >= achievement.requiredValue;
          break;
        case 'morning_habit':
          shouldUnlock = (morningDrinkDays ?? 0) >= achievement.requiredValue;
          break;
        case 'evening_habit':
          shouldUnlock = (eveningCompleteDays ?? 0) >= achievement.requiredValue;
          break;
        case 'frequency_habit':
          shouldUnlock = (frequencyDays ?? 0) >= achievement.requiredValue;
          break;
        case 'weekend_habit':
          shouldUnlock = (weekendGoalDays ?? 0) >= achievement.requiredValue;
          break;
        case 'comeback':
          shouldUnlock = (isComeback ?? false) && currentStreak >= achievement.requiredValue;
          break;
        case 'perfect_week':
          shouldUnlock = consecutiveGoals >= 7;
          break;
      }

      if (shouldUnlock) {
        final unlocked = achievement.unlock();
        await _achievementBox.put(achievement.id, unlocked);
        unlockedNow.add(unlocked);
      }
    }

    return unlockedNow;
  }

  /// Belirli bir başarımın kilidini aç
  Future<Achievement?> unlockAchievement(String id) async {
    final achievement = _achievementBox.get(id);
    if (achievement != null && !achievement.isUnlocked) {
      final unlocked = achievement.unlock();
      await _achievementBox.put(id, unlocked);
      return unlocked;
    }
    return null;
  }

  /// İlerleme değerini kaydet
  Future<void> saveProgress(String key, int value) async {
    await _progressBox.put(key, value);
  }

  /// İlerleme değerini al
  int getProgress(String key) {
    return _progressBox.get(key, defaultValue: 0);
  }

  /// İlerleme değerini artır
  Future<int> incrementProgress(String key, {int amount = 1}) async {
    final current = getProgress(key);
    final newValue = current + amount;
    await saveProgress(key, newValue);
    return newValue;
  }

  /// Başarım kategorilerine göre grupla
  Map<String, List<Achievement>> getAchievementsByCategory() {
    final achievements = getAllAchievements();
    final categories = <String, List<Achievement>>{
      'Seri Başarımları': [],
      'Hedef Başarımları': [],
      'Toplam Su Başarımları': [],
      'Alışkanlık Başarımları': [],
      'Özel Başarımlar': [],
    };

    for (final achievement in achievements) {
      switch (achievement.type) {
        case 'streak':
          categories['Seri Başarımları']!.add(achievement);
          break;
        case 'daily_goal':
        case 'consecutive_goals':
        case 'daily_percentage':
          categories['Hedef Başarımları']!.add(achievement);
          break;
        case 'total_intake':
          categories['Toplam Su Başarımları']!.add(achievement);
          break;
        case 'morning_habit':
        case 'evening_habit':
        case 'frequency_habit':
        case 'weekend_habit':
          categories['Alışkanlık Başarımları']!.add(achievement);
          break;
        default:
          categories['Özel Başarımlar']!.add(achievement);
      }
    }

    return categories;
  }

  /// Başarım istatistikleri
  AchievementStats getStats() {
    final all = getAllAchievements();
    final unlocked = all.where((a) => a.isUnlocked).length;
    
    return AchievementStats(
      total: all.length,
      unlocked: unlocked,
      completionPercentage: all.isEmpty ? 0 : (unlocked / all.length * 100),
    );
  }
}

/// Başarım istatistikleri
class AchievementStats {
  final int total;
  final int unlocked;
  final double completionPercentage;

  const AchievementStats({
    required this.total,
    required this.unlocked,
    required this.completionPercentage,
  });
}

