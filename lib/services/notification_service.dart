import 'dart:io';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/motivational_messages.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Bildirim servisini başlat
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Bildirime tıklandığında yapılacak işlem
    // Navigator ile uygulamayı açma işlemi burada yapılabilir
  }

  /// Bildirim izni iste
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// Periyodik hatırlatma bildirimleri ayarla
  Future<void> scheduleHydrationReminders({
    required int intervalMinutes,
    required int wakeUpHour,
    required int sleepHour,
  }) async {
    // Önce mevcut bildirimleri iptal et
    await cancelAllNotifications();

    // Uyanma ve uyuma saatleri arasında bildirim zamanları oluştur
    final now = DateTime.now();
    var notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      wakeUpHour,
      0,
    );

    // Eğer şu anki saat uyanma saatinden geçmişse, bir sonraki periyoddan başla
    if (now.hour >= wakeUpHour) {
      while (notificationTime.isBefore(now)) {
        notificationTime = notificationTime.add(Duration(minutes: intervalMinutes));
      }
    }

    int notificationId = 0;
    final sleepTime = DateTime(now.year, now.month, now.day, sleepHour, 0);

    while (notificationTime.isBefore(sleepTime) && notificationId < 20) {
      await _scheduleNotification(
        id: notificationId,
        title: MotivationalMessages.getRandomNotificationTitle(),
        body: MotivationalMessages.getRandomReminderMessage(),
        scheduledDate: notificationTime,
      );

      notificationTime = notificationTime.add(Duration(minutes: intervalMinutes));
      notificationId++;
    }
  }

  /// Tek bir bildirim zamanla
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'hydration_reminders',
      'Su Hatırlatmaları',
      channelDescription: 'Su içme hatırlatma bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF5DADE2),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte tekrarla
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Anlık bildirim göster
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Anlık Bildirimler',
      channelDescription: 'Anlık uygulama bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF5DADE2),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  /// Hedefe ulaşıldığında bildirim göster
  Future<void> showGoalReachedNotification() async {
    await showInstantNotification(
      title: '🎉 Tebrikler!',
      body: MotivationalMessages.getRandomGoalReachedMessage(),
    );
  }

  /// Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}


