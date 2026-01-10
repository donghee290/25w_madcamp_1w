import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. 초기화
  Future<void> init() async {
    // 타임존 데이터 초기화
    tz.initializeTimeZones();

    // 안드로이드 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정 (지금은 기본값)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 2. 권한 요청
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  // 3. 알람 예약
  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // 알람 ID
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local), // 시간 설정
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id', // 채널 ID
          'Alarm Channel', // 채널 이름
          channelDescription: '알람을 위한 채널입니다.',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('default_alarm'), // 소리 설정
          // (일단 기본 소리가 없으면 기본 알림음으로 대체됨)
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    print("[예약 완료] ID: $id / 시간: $scheduledTime");
  }

  // 4. 알람 취소
  Future<void> cancelAlarm(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("[취소 완료] ID: $id");
  }
}
