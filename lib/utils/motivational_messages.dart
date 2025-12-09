import 'dart:math';

/// Cesaretlendirici ve nazik mesajlar - Suçluluk hissi yaratmadan motive edici
class MotivationalMessages {
  MotivationalMessages._();

  static final Random _random = Random();

  /// Su ekleme sonrası mesajlar
  static const List<String> waterAddedMessages = [
    'Harika gidiyorsun! 💧',
    'Mükemmel bir adım! 🌟',
    'Vücudun sana teşekkür ediyor.',
    'Her yudum önemli! 💪',
    'Güzel iş çıkardın!',
    'Kendine bakıyorsun, bravo!',
    'Harikasın! 🎉',
    'Su içmek seni tazeler.',
    'Enerjin artıyor! ⚡',
    'Sağlıklı bir tercih yaptın.',
  ];

  /// Gün içi hatırlatma mesajları (nazik ton)
  static const List<String> reminderMessages = [
    '💧 Küçük bir yudum almak iyi gelebilir.',
    '🌊 Su içmek için güzel bir an.',
    '✨ Vücudun suya ihtiyaç duyuyor olabilir.',
    '💦 Bir bardak su nasıl olur?',
    '🌿 Kendine bir mola ver, biraz su iç.',
    '💧 Su içmek seni tazeler.',
    '🌸 Sağlığın için bir yudum?',
    '💎 Suyu unutma, değerli olan sensin!',
    '🌈 Biraz su içmenin tam zamanı.',
    '🌻 Vücuduna iyi bak, su iç.',
  ];

  /// Hedefe ulaşıldığında gösterilecek mesajlar
  static const List<String> goalReachedMessages = [
    '🎉 Bugünkü hedefine ulaştın! Tebrikler!',
    '🏆 Harika! Günlük su hedefini tamamladın!',
    '⭐ Muhteşemsin! Bugün hedefini başardın!',
    '🌟 Bravo! Su hedefin tamam!',
    '✨ İnanılmazsın! Hedefe vardın!',
    '🎊 Süpersin! Bugünkü görev tamamlandı!',
    '💪 Güçlü kaldın! Hedef başarıldı!',
    '🌈 Mükemmel! Bugün çok iyi iş çıkardın!',
  ];

  /// Seri devam mesajları
  static const List<String> streakMessages = [
    '🔥 {days} gündür düzenli içiyorsun!',
    '⚡ {days} günlük seri! Harikasın!',
    '🌟 {days} gün üst üste hedefe ulaştın!',
    '💪 {days} günlük başarı serisi!',
  ];

  /// Sabah karşılama mesajları
  static const List<String> morningGreetings = [
    'Günaydın! ☀️ Güne bir bardak suyla başla.',
    'Günaydın! 🌅 Vücudun suya hazır.',
    'Hoş geldin güne! 🌸 İlk yudumun hayırlı olsun.',
    'Günaydın! 💧 Bugün harika bir gün olacak.',
  ];

  /// Öğle karşılama mesajları
  static const List<String> afternoonGreetings = [
    'İyi öğlenler! 🌤️ Su içmeyi unutma.',
    'Günün ortasına geldik! ☀️ Nasıl gidiyor?',
    'İyi öğlenler! 💧 Enerjini koru.',
  ];

  /// Akşam karşılama mesajları
  static const List<String> eveningGreetings = [
    'İyi akşamlar! 🌙 Güne güzelce veda et.',
    'İyi akşamlar! 🌆 Bugün nasıl geçti?',
    'İyi akşamlar! ✨ Dinlenmeyi hak ediyorsun.',
  ];

  /// İlerleme mesajları (yüzdeye göre)
  static String getProgressMessage(double percentage) {
    if (percentage < 25) {
      return 'Güne yeni başladın, harika! 🌱';
    } else if (percentage < 50) {
      return 'Güzel gidiyorsun! 💧';
    } else if (percentage < 75) {
      return 'Yarıdan fazlasını tamamladın! 🌟';
    } else if (percentage < 100) {
      return 'Neredeyse hedefe ulaştın! 🎯';
    } else {
      return 'Bugünkü hedefini başardın! 🎉';
    }
  }

  /// Rastgele su ekleme mesajı
  static String getRandomWaterAddedMessage() {
    return waterAddedMessages[_random.nextInt(waterAddedMessages.length)];
  }

  /// Rastgele hatırlatma mesajı
  static String getRandomReminderMessage() {
    return reminderMessages[_random.nextInt(reminderMessages.length)];
  }

  /// Rastgele hedef mesajı
  static String getRandomGoalReachedMessage() {
    return goalReachedMessages[_random.nextInt(goalReachedMessages.length)];
  }

  /// Seri mesajı (gün sayısıyla)
  static String getStreakMessage(int days) {
    final message = streakMessages[_random.nextInt(streakMessages.length)];
    return message.replaceAll('{days}', days.toString());
  }

  /// Saate göre karşılama mesajı
  static String getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return morningGreetings[_random.nextInt(morningGreetings.length)];
    } else if (hour >= 12 && hour < 18) {
      return afternoonGreetings[_random.nextInt(afternoonGreetings.length)];
    } else {
      return eveningGreetings[_random.nextInt(eveningGreetings.length)];
    }
  }

  /// Bildirim başlıkları
  static const List<String> notificationTitles = [
    'Su Zamanı 💧',
    'Küçük Bir Mola ☕',
    'Sağlık Hatırlatması 🌿',
    'Hidrasyon Vakti 💦',
  ];

  /// Rastgele bildirim başlığı
  static String getRandomNotificationTitle() {
    return notificationTitles[_random.nextInt(notificationTitles.length)];
  }
}

