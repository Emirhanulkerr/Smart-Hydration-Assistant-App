import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'daily_stats.g.dart';

@HiveType(typeId: 2)
class DailyStats extends Equatable {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int totalAmount; // ml

  @HiveField(2)
  final int goal; // ml

  @HiveField(3)
  final int entryCount;

  @HiveField(4)
  final bool goalReached;

  const DailyStats({
    required this.date,
    required this.totalAmount,
    required this.goal,
    required this.entryCount,
    required this.goalReached,
  });

  factory DailyStats.empty(DateTime date, int goal) {
    return DailyStats(
      date: DateTime(date.year, date.month, date.day),
      totalAmount: 0,
      goal: goal,
      entryCount: 0,
      goalReached: false,
    );
  }

  double get progressPercentage => (totalAmount / goal * 100).clamp(0, 100);

  DailyStats copyWith({
    DateTime? date,
    int? totalAmount,
    int? goal,
    int? entryCount,
    bool? goalReached,
  }) {
    return DailyStats(
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      goal: goal ?? this.goal,
      entryCount: entryCount ?? this.entryCount,
      goalReached: goalReached ?? this.goalReached,
    );
  }

  @override
  List<Object?> get props => [date, totalAmount, goal, entryCount, goalReached];
}

@HiveType(typeId: 3)
class Achievement extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final DateTime? unlockedAt;

  @HiveField(5)
  final int requiredValue;

  @HiveField(6)
  final String type; // 'streak', 'total', 'daily'

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.requiredValue,
    required this.type,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement unlock() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlockedAt: DateTime.now(),
      requiredValue: requiredValue,
      type: type,
    );
  }

  @override
  List<Object?> get props => [id, title, description, icon, unlockedAt, requiredValue, type];
}

/// Önceden tanımlı başarılar
class Achievements {
  Achievements._();

  static const List<Achievement> all = [
    // Streak başarıları
    Achievement(
      id: 'streak_3',
      title: 'İlk Adım 🌱',
      description: '3 gün üst üste hedefine ulaş',
      icon: '🌱',
      requiredValue: 3,
      type: 'streak',
    ),
    Achievement(
      id: 'streak_7',
      title: 'Haftalık Kahraman 🌟',
      description: '7 gün üst üste hedefine ulaş',
      icon: '🌟',
      requiredValue: 7,
      type: 'streak',
    ),
    Achievement(
      id: 'streak_14',
      title: 'İki Haftalık Şampiyon 💪',
      description: '14 gün üst üste hedefine ulaş',
      icon: '💪',
      requiredValue: 14,
      type: 'streak',
    ),
    Achievement(
      id: 'streak_30',
      title: 'Aylık Efsane 🏆',
      description: '30 gün üst üste hedefine ulaş',
      icon: '🏆',
      requiredValue: 30,
      type: 'streak',
    ),
    // Toplam başarılar
    Achievement(
      id: 'total_10',
      title: 'Su Çömezi 💧',
      description: 'Toplam 10 litre su iç',
      icon: '💧',
      requiredValue: 10000,
      type: 'total',
    ),
    Achievement(
      id: 'total_50',
      title: 'Hidrasyon Uzmanı 🌊',
      description: 'Toplam 50 litre su iç',
      icon: '🌊',
      requiredValue: 50000,
      type: 'total',
    ),
    Achievement(
      id: 'total_100',
      title: 'Su Ustası 🎖️',
      description: 'Toplam 100 litre su iç',
      icon: '🎖️',
      requiredValue: 100000,
      type: 'total',
    ),
    // Günlük başarılar
    Achievement(
      id: 'daily_first',
      title: 'İlk Yudum ✨',
      description: 'İlk kez hedefine ulaş',
      icon: '✨',
      requiredValue: 1,
      type: 'daily',
    ),
    Achievement(
      id: 'daily_120',
      title: 'Ekstra Hidrasyon 💦',
      description: 'Günlük hedefini %120 aş',
      icon: '💦',
      requiredValue: 120,
      type: 'daily_percentage',
    ),
  ];
}

