import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  Future<void> init() async {
    tz.initializeTimeZones();
    // 한국 시간대 설정 (Asia/Seoul)
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (e) {
      // Timezone error
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        selectNotificationStream.add(notificationResponse.payload);
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  // 알람 설정 (매주 반복) - Updated
  Future<void> scheduleAlarm({
    required int alarmId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> weekdays,
    required String payload,
    int duration = 5,
  }) async {
    
    // 만약 요일이 선택되지 않았다면(일회성 등), 혹은 매일 반복?
    // 여기서는 weekdays에 있는 요일마다 각각 Notification schedule을 건다.
    // ID 규칙: AlarmID * 100 + weekday (예: 알람ID 1 => 101(월), 102(화)...) 
    // 하지만 ID는 int 범위 내여야 함.
    // 기존 id가 unique int라고 가정.

    if (weekdays.isEmpty) {
      // 요일 미선택 -> 일회성 알람 (오늘 or 내일)
      await _scheduleOneTimeNotification(
        id: alarmId,
        hour: hour,
        minute: minute,
        title: title,
        body: body,
        payload: payload,
      );
    } else {
      for (int weekday in weekdays) {
        await _scheduleWeeklyNotification(
          id: alarmId,
          weekday: weekday,
          hour: hour,
          minute: minute,
          title: title,
          body: body,
          payload: payload,
        );
      }
    }
  }

  Future<void> _scheduleOneTimeNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      _generateNotificationId(id, 0), // 0 for One-time
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm Channel',
          channelDescription: 'Channel for Alarm Notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // No matchDateTimeComponents -> One time
      payload: payload,
    );
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    // weekday: 1(Mon) ~ 7(Sun)
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      _generateNotificationId(id, weekday),
      title,
      body,
      _nextInstanceOfDayAndTime(weekday, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm Channel',
          channelDescription: 'Channel for Alarm Notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // 풀스크린 인텐트 (알람 화면 띄우기 위함)
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  // 알람 취소
  Future<void> cancelAlarm(int id) async {
    // 0(One-time) ~ 7(Sun)
    for (int weekday = 0; weekday <= 7; weekday++) {
      await flutterLocalNotificationsPlugin.cancel(
        _generateNotificationId(id, weekday),
      );
    }
  }
  
  // 모든 알람 취소
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // ID 생성 (충돌 방지용 단순 로직)
  int _generateNotificationId(int alarmId, int weekday) {
    // alarmId가 보통 timestamp 등 큰 수일 수 잇으므로 유의. 
    // 여기서는 alarmId가 Hive ID(String)의 hashCode라고 가정하거나 별도 int ID 관리 필요.
    // Alarm Model의 id는 String임. 호출부에서 hashcode를 쓴다고 가정.
    // 그러나 hashcode는 음수가 될수도 있고 큼.
    // 간단히: (alarmId % 100000) * 10 + weekday
    return (alarmId % 100000) * 10 + weekday;
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 요일 보정
    // weekday: 1=Mon...7=Sun
    // scheduledDate.weekday: 1=Mon...7=Sun
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 만약 계산된 시간이 현재보다 이전이면 7일 뒤로 (다음주)
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
