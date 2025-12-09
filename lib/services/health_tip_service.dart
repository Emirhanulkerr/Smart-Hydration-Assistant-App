import 'dart:math';
import '../models/health_tip.dart';

/// Kişiselleştirilmiş sağlık önerileri üreten servis
class HealthTipService {
  final Random _random = Random();

  /// Mevcut duruma göre sağlık önerisi üret
  HealthTip generateTip({
    required double dailyIntake,
    required double dailyGoal,
    required int streak,
    required double progressPercentage,
    int? hourOfDay,
  }) {
    final hour = hourOfDay ?? DateTime.now().hour;

    // Öncelik sırasına göre öneri seç
    if (progressPercentage >= 100) {
      return _getGoalExceededTip(progressPercentage, streak);
    } else if (progressPercentage >= 90) {
      return _getAlmostThereTip(dailyGoal - dailyIntake);
    } else if (progressPercentage >= 70) {
      return _getGoodProgressTip(streak);
    } else if (progressPercentage >= 50) {
      return _getMidProgressTip(hour);
    } else if (progressPercentage >= 25) {
      return _getLowProgressTip(hour);
    } else {
      return _getStartingTip(hour);
    }
  }

  /// Sabah saatlerinde özel öneri
  HealthTip getMorningTip() {
    final tips = [
      HealthTip.create(
        message: 'Günaydın! Bir bardak su ile güne başlamak metabolizmanı hızlandırır.',
        level: HealthTipLevel.calm,
        type: HealthTipType.morning,
        emoji: '🌅',
      ),
      HealthTip.create(
        message: 'Sabah suyu içmek gece boyunca kaybedilen sıvıyı yerine koyar.',
        level: HealthTipLevel.calm,
        type: HealthTipType.morning,
        emoji: '☀️',
      ),
      HealthTip.create(
        message: 'Kahvaltıdan önce bir bardak su sindirim sistemini aktive eder.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.morning,
        emoji: '🌻',
      ),
    ];
    return tips[_random.nextInt(tips.length)];
  }

  /// Akşam saatlerinde özel öneri
  HealthTip getEveningTip(double progressPercentage) {
    if (progressPercentage >= 100) {
      return HealthTip.create(
        message: 'Bugün hedefini tamamladın! Uyumadan önce ılık su sindirimi destekler.',
        level: HealthTipLevel.celebration,
        type: HealthTipType.evening,
        emoji: '🌙',
      );
    } else if (progressPercentage >= 70) {
      return HealthTip.create(
        message: 'Güzel bir gün geçirdin! Biraz daha su ile günü tamamlayabilirsin.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.evening,
        emoji: '✨',
      );
    } else {
      return HealthTip.create(
        message: 'Akşamları da su içmek unutulmamalı. Yarın yeni bir fırsat!',
        level: HealthTipLevel.calm,
        type: HealthTipType.evening,
        emoji: '🌜',
      );
    }
  }

  /// Streak durumuna göre öneri
  HealthTip getStreakTip(int streak, bool isAtRisk) {
    if (isAtRisk) {
      return HealthTip.create(
        message: 'Serini korumak için bugün biraz daha su içebilirsin. Yapabilirsin!',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.streak,
        emoji: '💪',
      );
    }

    if (streak >= 30) {
      final tips = [
        'Bir ay boyunca düzenli su içtin! Vücudun buna çok mutlu.',
        '${streak} günlük seri! Bu harika bir alışkanlık.',
        'Senin gibi kararlı insanlar başarır. ${streak} gün harika!',
      ];
      return HealthTip.create(
        message: tips[_random.nextInt(tips.length)],
        level: HealthTipLevel.celebration,
        type: HealthTipType.streak,
        emoji: '🏆',
      );
    } else if (streak >= 7) {
      final tips = [
        '${streak} günlük seri! Vücudun bu düzeni çok seviyor.',
        'Bir haftadan fazla! Harika gidiyorsun.',
        'Aynen devam! ${streak} gün çok iyi.',
      ];
      return HealthTip.create(
        message: tips[_random.nextInt(tips.length)],
        level: HealthTipLevel.encouraging,
        type: HealthTipType.streak,
        emoji: '🔥',
      );
    } else if (streak >= 3) {
      return HealthTip.create(
        message: '${streak} günlük seri! Alışkanlık oluşuyor.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.streak,
        emoji: '⭐',
      );
    } else {
      return HealthTip.create(
        message: 'Her gün su içmek harika bir alışkanlık. Devam et!',
        level: HealthTipLevel.calm,
        type: HealthTipType.streak,
        emoji: '💧',
      );
    }
  }

  // ===== Private Methods =====

  HealthTip _getGoalExceededTip(double progress, int streak) {
    final tips = [
      HealthTip.create(
        message: 'Harika iş çıkardın! Bugünkü hedefini tamamladın. Artık dengeyi koruma vakti 😊',
        level: HealthTipLevel.celebration,
        type: HealthTipType.progress,
        emoji: '🎉',
      ),
      HealthTip.create(
        message: 'Tebrikler! Bugün kendine çok iyi baktın.',
        level: HealthTipLevel.celebration,
        type: HealthTipType.progress,
        emoji: '✨',
      ),
      HealthTip.create(
        message: 'Hedefi aştın! Vücudun sana teşekkür ediyor.',
        level: HealthTipLevel.celebration,
        type: HealthTipType.progress,
        emoji: '🌟',
      ),
    ];
    return tips[_random.nextInt(tips.length)];
  }

  HealthTip _getAlmostThereTip(double remaining) {
    final mlRemaining = remaining.round();
    final tips = [
      HealthTip.create(
        message: 'Harikasın! Sadece $mlRemaining ml daha içersen hedefi tamamlıyorsun.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.progress,
        emoji: '🎯',
      ),
      HealthTip.create(
        message: 'Neredeyse tamam! Son $mlRemaining ml için bir bardak daha.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.progress,
        emoji: '💪',
      ),
    ];
    return tips[_random.nextInt(tips.length)];
  }

  HealthTip _getGoodProgressTip(int streak) {
    final tips = [
      HealthTip.create(
        message: 'Güzel gidiyorsun! Hedefe yaklaşıyorsun.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.progress,
        emoji: '👍',
      ),
      HealthTip.create(
        message: 'İyi ilerleme! Biraz daha su seni hedefine yaklaştırır.',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.progress,
        emoji: '🌊',
      ),
    ];
    return tips[_random.nextInt(tips.length)];
  }

  HealthTip _getMidProgressTip(int hour) {
    if (hour < 14) {
      return HealthTip.create(
        message: 'Öğleden sonra için güzel bir başlangıç. Devam et!',
        level: HealthTipLevel.calm,
        type: HealthTipType.progress,
        emoji: '☀️',
      );
    } else {
      final tips = [
        HealthTip.create(
          message: 'Günün yarısında yarı yoldasın. Harika tempo!',
          level: HealthTipLevel.encouraging,
          type: HealthTipType.progress,
          emoji: '⚡',
        ),
        HealthTip.create(
          message: 'Biraz daha su enerjini artırabilir.',
          level: HealthTipLevel.calm,
          type: HealthTipType.hydration,
          emoji: '💧',
        ),
      ];
      return tips[_random.nextInt(tips.length)];
    }
  }

  HealthTip _getLowProgressTip(int hour) {
    if (hour >= 18) {
      return HealthTip.create(
        message: 'Bugün biraz geride kaldın ama yarın yeni bir gün. Şimdi bir yudum?',
        level: HealthTipLevel.calm,
        type: HealthTipType.reminder,
        emoji: '🌸',
      );
    }
    final tips = [
      HealthTip.create(
        message: 'Küçük bir yudum metabolizmanı canlandırır.',
        level: HealthTipLevel.calm,
        type: HealthTipType.hydration,
        emoji: '💧',
      ),
      HealthTip.create(
        message: 'Biraz su içmek baş ağrısını azaltabilir.',
        level: HealthTipLevel.calm,
        type: HealthTipType.hydration,
        emoji: '🧠',
      ),
      HealthTip.create(
        message: 'Su içmek konsantrasyonu artırır.',
        level: HealthTipLevel.calm,
        type: HealthTipType.hydration,
        emoji: '🎯',
      ),
    ];
    return tips[_random.nextInt(tips.length)];
  }

  HealthTip _getStartingTip(int hour) {
    if (hour < 10) {
      return getMorningTip();
    }
    final tips = [
      HealthTip.create(
        message: 'Bugün yavaş başlaman normal. Bir yudum iyi gelebilir.',
        level: HealthTipLevel.calm,
        type: HealthTipType.reminder,
        emoji: '🌱',
      ),
      HealthTip.create(
        message: 'Her yolculuk tek bir adımla başlar. İlk yudumunu al!',
        level: HealthTipLevel.encouraging,
        type: HealthTipType.reminder,
        emoji: '🚀',
      ),
      HealthTip.create(
        message: 'Vücudun suya ihtiyaç duyuyor. Küçük bir başlangıç yap.',
        level: HealthTipLevel.calm,
        type: HealthTipType.hydration,
        emoji: '💦',
      ),
    ];
    return tips[_random.nextInt(tips.length)];
  }

  /// Genel sağlık önerileri listesi
  List<HealthTip> getGeneralHealthTips() {
    return [
      HealthTip.create(
        message: 'Yeterli su içmek cilt sağlığını destekler.',
        level: HealthTipLevel.calm,
        type: HealthTipType.general,
        emoji: '✨',
      ),
      HealthTip.create(
        message: 'Su içmek toksinlerin vücuttan atılmasına yardımcı olur.',
        level: HealthTipLevel.calm,
        type: HealthTipType.general,
        emoji: '🌿',
      ),
      HealthTip.create(
        message: 'Düzenli su tüketimi enerji seviyeni yüksek tutar.',
        level: HealthTipLevel.calm,
        type: HealthTipType.general,
        emoji: '⚡',
      ),
      HealthTip.create(
        message: 'Su içmek sindirim sisteminin düzgün çalışmasını sağlar.',
        level: HealthTipLevel.calm,
        type: HealthTipType.general,
        emoji: '🌻',
      ),
      HealthTip.create(
        message: 'Yeterli hidrasyon eklem sağlığını destekler.',
        level: HealthTipLevel.calm,
        type: HealthTipType.general,
        emoji: '💪',
      ),
      HealthTip.create(
        message: 'Su, beyin fonksiyonları için kritik öneme sahiptir.',
        level: HealthTipLevel.calm,
        type: HealthTipType.general,
        emoji: '🧠',
      ),
    ];
  }
}

