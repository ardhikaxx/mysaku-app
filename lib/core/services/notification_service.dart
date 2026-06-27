import 'package:flutter/foundation.dart';
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

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required bool isEnabled,
  }) async {
    await init();

    const int notificationId = 888;
    await _notificationsPlugin.cancel(id: notificationId);

    if (!isEnabled) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final Int64List vibrationPattern = Int64List.fromList([0, 500, 250, 500]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mysaku_daily_reminder',
      'Pengingat Catat Harian',
      channelDescription:
          'Notifikasi pengingat untuk mencatat transaksi keuangan harian MySaku',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      playSound: true,
      styleInformation: const BigTextStyleInformation(
        'Yuk luangkan 1 menit untuk mencatat pemasukan & pengeluaranmu hari ini di MySaku agar keuanganmu tetap terkontrol!',
        contentTitle: '🌙 Sudah catat keuanganmu hari ini?',
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

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: '🌙 Sudah catat keuanganmu hari ini?',
      body:
          'Yuk luangkan 1 menit untuk mencatat pemasukan & pengeluaranmu hari ini di MySaku!',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showInstantTestNotification() async {
    await init();

    final Int64List vibrationPattern = Int64List.fromList([0, 500, 250, 500]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mysaku_daily_reminder',
      'Pengingat Catat Harian',
      channelDescription: 'Notifikasi pengingat keuangan harian MySaku',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.show(
      id: 999,
      title: '🔔 Uji Coba Pengingat MySaku',
      body:
          'Pengingat harian aktif! Ponsel bergetar dan memberi pesan saat layar tertutup.',
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
