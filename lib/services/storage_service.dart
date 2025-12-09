import 'package:hive_flutter/hive_flutter.dart';
import '../models/water_entry.dart';
import '../models/user_settings.dart';
import '../models/daily_stats.dart';

class StorageService {
  static const String _waterEntriesBox = 'water_entries';
  static const String _userSettingsBox = 'user_settings';
  static const String _dailyStatsBox = 'daily_stats';
  static const String _achievementsBox = 'achievements';
  
  static const String _settingsKey = 'settings';

  late Box<WaterEntry> _waterEntriesBoxInstance;
  late Box<UserSettings> _userSettingsBoxInstance;
  late Box<DailyStats> _dailyStatsBoxInstance;
  late Box<Achievement> _achievementsBoxInstance;

  /// Hive'ı başlat ve kutuları aç
  Future<void> init() async {
    await Hive.initFlutter();

    // Adapter'ları kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WaterEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DailyStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AchievementAdapter());
    }

    // Kutuları aç
    _waterEntriesBoxInstance = await Hive.openBox<WaterEntry>(_waterEntriesBox);
    _userSettingsBoxInstance = await Hive.openBox<UserSettings>(_userSettingsBox);
    _dailyStatsBoxInstance = await Hive.openBox<DailyStats>(_dailyStatsBox);
    _achievementsBoxInstance = await Hive.openBox<Achievement>(_achievementsBox);
  }

  // ==================== Water Entries ====================

  /// Su girdisi ekle
  Future<void> addWaterEntry(WaterEntry entry) async {
    await _waterEntriesBoxInstance.put(entry.id, entry);
  }

  /// Su girdisi sil
  Future<void> deleteWaterEntry(String id) async {
    await _waterEntriesBoxInstance.delete(id);
  }

  /// Tüm su girdilerini al
  List<WaterEntry> getAllWaterEntries() {
    return _waterEntriesBoxInstance.values.toList();
  }

  /// Belirli bir günün su girdilerini al
  List<WaterEntry> getWaterEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _waterEntriesBoxInstance.values
        .where((entry) =>
            entry.timestamp.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            entry.timestamp.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Belirli bir tarih aralığındaki girdileri al
  List<WaterEntry> getWaterEntriesInRange(DateTime start, DateTime end) {
    return _waterEntriesBoxInstance.values
        .where((entry) =>
            entry.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
            entry.timestamp.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Bugünkü toplam su miktarını al
  int getTodayTotalAmount() {
    final entries = getWaterEntriesForDate(DateTime.now());
    return entries.fold(0, (sum, entry) => sum + entry.amount);
  }

  // ==================== User Settings ====================

  /// Kullanıcı ayarlarını al
  UserSettings getSettings() {
    return _userSettingsBoxInstance.get(_settingsKey) ?? const UserSettings();
  }

  /// Kullanıcı ayarlarını kaydet
  Future<void> saveSettings(UserSettings settings) async {
    await _userSettingsBoxInstance.put(_settingsKey, settings);
  }

  // ==================== Daily Stats ====================

  /// Günlük istatistik kaydet
  Future<void> saveDailyStats(DailyStats stats) async {
    final key = _dateToKey(stats.date);
    await _dailyStatsBoxInstance.put(key, stats);
  }

  /// Belirli bir günün istatistiğini al
  DailyStats? getDailyStats(DateTime date) {
    final key = _dateToKey(date);
    return _dailyStatsBoxInstance.get(key);
  }

  /// Tarih aralığındaki istatistikleri al
  List<DailyStats> getDailyStatsInRange(DateTime start, DateTime end) {
    final stats = <DailyStats>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      final stat = getDailyStats(current);
      if (stat != null) {
        stats.add(stat);
      }
      current = current.add(const Duration(days: 1));
    }

    return stats;
  }

  /// Mevcut seriyi hesapla (ardışık hedefe ulaşılan günler)
  int getCurrentStreak() {
    var streak = 0;
    var checkDate = DateTime.now();
    
    // Bugün henüz hedefe ulaşılmamışsa dünden başla
    final todayStats = getDailyStats(checkDate);
    if (todayStats == null || !todayStats.goalReached) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final stats = getDailyStats(checkDate);
      if (stats != null && stats.goalReached) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Toplam içilen su miktarı
  int getTotalWaterEver() {
    return _dailyStatsBoxInstance.values.fold(0, (sum, stat) => sum + stat.totalAmount);
  }

  // ==================== Achievements ====================

  /// Başarıları al
  List<Achievement> getAchievements() {
    if (_achievementsBoxInstance.isEmpty) {
      // İlk kez açılıyorsa varsayılan başarıları ekle
      for (final achievement in Achievements.all) {
        _achievementsBoxInstance.put(achievement.id, achievement);
      }
    }
    return _achievementsBoxInstance.values.toList();
  }

  /// Başarı güncelle
  Future<void> updateAchievement(Achievement achievement) async {
    await _achievementsBoxInstance.put(achievement.id, achievement);
  }

  /// Başarıyı kilitle açık olarak işaretle
  Future<Achievement?> unlockAchievement(String id) async {
    final achievement = _achievementsBoxInstance.get(id);
    if (achievement != null && !achievement.isUnlocked) {
      final unlocked = achievement.unlock();
      await _achievementsBoxInstance.put(id, unlocked);
      return unlocked;
    }
    return null;
  }

  // ==================== Helpers ====================

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Tüm verileri temizle
  Future<void> clearAllData() async {
    await _waterEntriesBoxInstance.clear();
    await _dailyStatsBoxInstance.clear();
    await _achievementsBoxInstance.clear();
  }
}

