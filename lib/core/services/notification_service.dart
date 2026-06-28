import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      String tzName = 'Asia/Jakarta';
      try {
        tzName = tzInfo.id ?? tzInfo.name ?? tzInfo.toString();
      } catch (_) {
        tzName = tzInfo.toString();
      }
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(settings: initializationSettings);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<bool> requestPermissionNow() async {
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      debugPrint('Requested notification permission from UI: $granted');
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleDailyReminder({
    int? hour,
    int? minute,
    required bool isEnabled,
  }) async {
    await init();

    final List<Map<String, dynamic>> schedules = [
      {
        'id': 801,
        'hour': 8,
        'minute': 0,
        'title': '🌅 Jam 08.00 - Selamat Pagi!',
        'body': 'Awali hari dengan rapi! Yuk catat pengeluaran sarapan atau persiapan harimu di MySaku.',
      },
      {
        'id': 802,
        'hour': 12,
        'minute': 0,
        'title': '☀️ Jam 12.00 - Istirahat Siang',
        'body': 'Sudah makan siang? Jangan lupa catat pengeluaranmu barusan di MySaku ya!',
      },
      {
        'id': 803,
        'hour': 15,
        'minute': 0,
        'title': '☕ Jam 15.00 - Waktu Sore & Jajan',
        'body': 'Ada beli kopi atau jajan sore ini? Yuk luangkan 10 detik catat di MySaku.',
      },
      {
        'id': 804,
        'hour': 18,
        'minute': 0,
        'title': '🌆 Jam 18.00 - Petang & Malam',
        'body': 'Sore menjelang malam! Yuk rapihkan catatan transaksi pengeluaran hari ini.',
      },
      {
        'id': 805,
        'hour': 21,
        'minute': 0,
        'title': '🌙 Jam 21.00 - Evaluasi Harian',
        'body': 'Sebelum istirahat malam, pastikan seluruh transaksi harimu sudah tercatat rapi!',
      },
    ];

    for (var s in schedules) {
      await _notificationsPlugin.cancel(id: s['id'] as int);
    }
    await _notificationsPlugin.cancel(id: 888);

    if (!isEnabled) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    for (var s in schedules) {
      final int id = s['id'] as int;
      final int h = s['hour'] as int;
      final int m = s['minute'] as int;
      final String title = s['title'] as String;
      final String body = s['body'] as String;

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        h,
        m,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'mysaku_notifications_channel_v2',
        'Notifikasi & Pengingat MySaku',
        channelDescription:
            'Saluran utama untuk notifikasi dan pengingat keuangan MySaku',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF1E3A8A),
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        debugPrint('Exact alarm failed, falling back to inexact: $e');
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  Future<void> showInstantTestNotification() async {
    await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mysaku_notifications_channel_v2',
      'Notifikasi & Pengingat MySaku',
      channelDescription: 'Saluran utama untuk notifikasi dan pengingat keuangan MySaku',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      playSound: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1E3A8A),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.show(
      id: 999,
      title: 'Notifikasi MySaku',
      body:
          'Berhasil! Ponsel Anda memunculkan pengingat otomatis.',
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
