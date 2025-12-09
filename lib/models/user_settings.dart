import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 1)
class UserSettings extends Equatable {
  @HiveField(0)
  final int dailyGoal; // ml cinsinden

  @HiveField(1)
  final int weight; // kg cinsinden

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final int notificationIntervalMinutes;

  @HiveField(4)
  final String selectedTheme; // 'light', 'dark', 'system'

  @HiveField(5)
  final String selectedCupIcon; // 'glass', 'bottle', 'mug'

  @HiveField(6)
  final int defaultCupSize; // ml cinsinden

  @HiveField(7)
  final bool adaptiveNotifications;

  @HiveField(8)
  final String? userName;

  @HiveField(9)
  final int wakeUpHour;

  @HiveField(10)
  final int sleepHour;

  @HiveField(11)
  final bool onboardingCompleted;

  @HiveField(12)
  final int selectedColorIndex;

  const UserSettings({
    this.dailyGoal = 2000,
    this.weight = 70,
    this.notificationsEnabled = true,
    this.notificationIntervalMinutes = 60,
    this.selectedTheme = 'system',
    this.selectedCupIcon = 'glass',
    this.defaultCupSize = 250,
    this.adaptiveNotifications = true,
    this.userName,
    this.wakeUpHour = 7,
    this.sleepHour = 23,
    this.onboardingCompleted = false,
    this.selectedColorIndex = 0,
  });

  /// Kiloya göre önerilen günlük su miktarını hesapla
  static int calculateRecommendedGoal(int weightKg) {
    // Genel kural: Kilo başına 30-35ml
    return (weightKg * 33).clamp(1500, 4000);
  }

  UserSettings copyWith({
    int? dailyGoal,
    int? weight,
    bool? notificationsEnabled,
    int? notificationIntervalMinutes,
    String? selectedTheme,
    String? selectedCupIcon,
    int? defaultCupSize,
    bool? adaptiveNotifications,
    String? userName,
    int? wakeUpHour,
    int? sleepHour,
    bool? onboardingCompleted,
    int? selectedColorIndex,
  }) {
    return UserSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      weight: weight ?? this.weight,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationIntervalMinutes: notificationIntervalMinutes ?? this.notificationIntervalMinutes,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedCupIcon: selectedCupIcon ?? this.selectedCupIcon,
      defaultCupSize: defaultCupSize ?? this.defaultCupSize,
      adaptiveNotifications: adaptiveNotifications ?? this.adaptiveNotifications,
      userName: userName ?? this.userName,
      wakeUpHour: wakeUpHour ?? this.wakeUpHour,
      sleepHour: sleepHour ?? this.sleepHour,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
    );
  }

  @override
  List<Object?> get props => [
        dailyGoal,
        weight,
        notificationsEnabled,
        notificationIntervalMinutes,
        selectedTheme,
        selectedCupIcon,
        defaultCupSize,
        adaptiveNotifications,
        userName,
        wakeUpHour,
        sleepHour,
        onboardingCompleted,
        selectedColorIndex,
      ];
}

