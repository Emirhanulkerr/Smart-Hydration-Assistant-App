import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'badge_model.g.dart';

/// Rozet kategorisi
enum BadgeCategory {
  streak,     // Seri bazlı
  hydration,  // Su içme bazlı
  special,    // Özel başarımlar
}

/// Soft Badge (Rozet) modeli
@HiveType(typeId: 10)
class Badge extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final bool unlocked;

  @HiveField(5)
  final DateTime? unlockedAt;

  @HiveField(6)
  final int streakRequired;

  @HiveField(7)
  final String category;

  @HiveField(8)
  final String congratsMessage;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlocked = false,
    this.unlockedAt,
    required this.streakRequired,
    required this.category,
    required this.congratsMessage,
  });

  Badge copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    bool? unlocked,
    DateTime? unlockedAt,
    int? streakRequired,
    String? category,
    String? congratsMessage,
  }) {
    return Badge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      streakRequired: streakRequired ?? this.streakRequired,
      category: category ?? this.category,
      congratsMessage: congratsMessage ?? this.congratsMessage,
    );
  }

  Badge unlock() {
    return copyWith(
      unlocked: true,
      unlockedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        emoji,
        unlocked,
        unlockedAt,
        streakRequired,
        category,
      ];
}

/// Tüm rozetler
class Badges {
  Badges._();

  /// Taze Başlangıç - 3 günlük streak
  static const freshStart = Badge(
    id: 'fresh_start',
    title: 'Taze Başlangıç',
    description: '3 gün boyunca düzenli su içtin',
    emoji: '🌱',
    streakRequired: 3,
    category: 'streak',
    congratsMessage: 'Harika bir başlangıç yaptın! Bu rozet sana çok yakıştı! 🌱',
  );

  /// Ritmini Buldun - 7 günlük streak
  static const foundRhythm = Badge(
    id: 'found_rhythm',
    title: 'Ritmini Buldun',
    description: '7 gün boyunca alışkanlığını sürdürdün',
    emoji: '🎵',
    streakRequired: 7,
    category: 'streak',
    congratsMessage: 'Muhteşem! Artık su içmek bir ritim haline geldi! 🎵',
  );

  /// Hidrasyon Ustası - 14 günlük streak
  static const hydrationMaster = Badge(
    id: 'hydration_master',
    title: 'Hidrasyon Ustası',
    description: '14 gün boyunca hedeflerine ulaştın',
    emoji: '💎',
    streakRequired: 14,
    category: 'streak',
    congratsMessage: 'İnanılmazsın! Hidrasyon konusunda gerçek bir usta oldun! 💎',
  );

  /// Ayın Su Kahramanı - 30 günlük streak
  static const monthlyHero = Badge(
    id: 'monthly_hero',
    title: 'Ayın Su Kahramanı',
    description: 'Bir ay boyunca düzenli su içtin',
    emoji: '🏅',
    streakRequired: 30,
    category: 'streak',
    congratsMessage: 'Efsane! Bir ay boyunca kararlılığını gösterdin! 🏅',
  );

  /// Efsanevi Hidrasyon - 100 günlük streak
  static const legendaryHydration = Badge(
    id: 'legendary_hydration',
    title: 'Efsanevi Hidrasyon',
    description: '100 gün boyunca hiç aksatmadın',
    emoji: '👑',
    streakRequired: 100,
    category: 'streak',
    congratsMessage: 'Sen bir efsanesin! 100 günlük bu başarı inanılmaz! 👑',
  );

  /// Tüm rozetler listesi
  static List<Badge> get allBadges => [
        freshStart,
        foundRhythm,
        hydrationMaster,
        monthlyHero,
        legendaryHydration,
      ];

  /// Streak'e göre açılacak rozetleri bul
  static List<Badge> getBadgesForStreak(int streak) {
    return allBadges.where((badge) => badge.streakRequired <= streak).toList();
  }
}

