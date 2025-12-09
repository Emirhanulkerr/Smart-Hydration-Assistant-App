import 'package:equatable/equatable.dart';

/// Sağlık önerisi seviyesi
enum HealthTipLevel {
  calm,        // Sakin, bilgilendirici
  encouraging, // Cesaretlendirici
  celebration, // Kutlama
  reminder,    // Nazik hatırlatma
}

/// Sağlık önerisi tipi
enum HealthTipType {
  hydration,     // Hidrasyon ile ilgili
  streak,        // Seri ile ilgili
  progress,      // İlerleme ile ilgili
  morning,       // Sabah önerisi
  evening,       // Akşam önerisi
  achievement,   // Başarım ile ilgili
  general,       // Genel sağlık
  reminder,      // Hatırlatma
}

/// Kişiselleştirilmiş sağlık önerisi modeli
class HealthTip extends Equatable {
  final String id;
  final String message;
  final HealthTipLevel level;
  final HealthTipType type;
  final String? emoji;
  final DateTime createdAt;

  const HealthTip({
    required this.id,
    required this.message,
    required this.level,
    required this.type,
    this.emoji,
    required this.createdAt,
  });

  factory HealthTip.create({
    required String message,
    required HealthTipLevel level,
    required HealthTipType type,
    String? emoji,
  }) {
    return HealthTip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      level: level,
      type: type,
      emoji: emoji,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, message, level, type, emoji, createdAt];
}

/// Streak durumu
class StreakStatus extends Equatable {
  final int currentStreak;
  final int bestStreak;
  final int forgivenessDaysLeft; // Kalan affetme günü
  final bool isAtRisk; // Streak risk altında mı
  final DateTime? lastUpdateDate;
  final List<double> recentProgress; // Son 7 günün ilerleme yüzdeleri

  const StreakStatus({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.forgivenessDaysLeft = 1,
    this.isAtRisk = false,
    this.lastUpdateDate,
    this.recentProgress = const [],
  });

  StreakStatus copyWith({
    int? currentStreak,
    int? bestStreak,
    int? forgivenessDaysLeft,
    bool? isAtRisk,
    DateTime? lastUpdateDate,
    List<double>? recentProgress,
  }) {
    return StreakStatus(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      forgivenessDaysLeft: forgivenessDaysLeft ?? this.forgivenessDaysLeft,
      isAtRisk: isAtRisk ?? this.isAtRisk,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      recentProgress: recentProgress ?? this.recentProgress,
    );
  }

  @override
  List<Object?> get props => [
        currentStreak,
        bestStreak,
        forgivenessDaysLeft,
        isAtRisk,
        lastUpdateDate,
        recentProgress,
      ];
}

