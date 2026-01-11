import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream to handle notification clicks (if needed for UI)
  final BehaviorSubject<String?> selectNotificationStream =
      BehaviorSubject<String?>();

  // 1. 초기화
  Future<void> init() async {
    tz.initializeTimeZones();
    // Getting the time zone of the device
    // Getting the time zone of the device
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      print("System Timezone: $timeZoneName");
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      print("Failed to get/set timezone: $e");
      // Fallback to Seoul (or UTC)
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'snooze_id') {
          // Snooze Action logic
          // Payload format: "originalId|durationMinutes|snoozeCount"
          if (response.payload != null) {
            final parts = response.payload!.split('|');
            if (parts.length >= 2) {
              final int originalId = int.parse(parts[0]);
              final int durationMin = int.parse(parts[1]);

              print("[Snooze] Clicked! Rescheduling in $durationMin minutes.");

              // Reschedule
              await _scheduleSnooze(originalId, durationMin);
            }
          }
        } else {
          // Normal Notification Tap (Dismissal)
          // Pass payload to stream for handling navigation
          if (response.payload != null) {
            selectNotificationStream.add(response.payload);
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // Snooze 내부 스케줄링 로직
  Future<void> _scheduleSnooze(int originalId, int durationMin) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime snoozeTime = now.add(Duration(minutes: durationMin));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm Channel',
          channelDescription: '알람을 위한 채널입니다.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      originalId + 999999, // 임시 Snooze ID (충돌 방지용)
      "미룬 알람",
      "일어나세요!",
      snoozeTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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

  // 3. 알람 예약 (단발성 및 반복성 통합 처리)
  Future<void> scheduleAlarm({
    required int alarmId, // Alarm 객체의 id.hashCode
    required String title,
    required String body,
    required int hour,
    required int minute,
    List<int> weekdays = const [], // 비어있으면 1회성, 있으면 요일 반복 (1:월 ~ 7:일)
    int duration = 5, // Snooze Interval (분)
  }) async {
    // 알림 설정 (공통)
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm Channel',
          channelDescription: '알람을 위한 채널입니다.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true, // 기본 소리 사용
          // ### Snooze Action 추가 ###
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'snooze_id',
              '미루기 (5분)', // 텍스트를 duration에 맞춰 동적으로 하면 좋겠지만 상수로 둠
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    // A. 반복 알람 (Weekdays가 있는 경우)
    if (weekdays.isNotEmpty) {
      for (int weekday in weekdays) {
        // 반복 알람의 경우, 각 요일별로 별도의 ID가 필요함 (충돌 방지)
        // 예: 알람ID가 123이고 월요일(1)이면 -> 1231
        // 주의: alarmId가 너무 크면 int 범위 초과 가능성 있음 (MVP 레벨에선 이 방식 사용)
        int uniqueId = _generateUniqueId(alarmId, weekday);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          uniqueId,
          title,
          body,
          _nextInstanceOfDay(weekday, hour, minute),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // 핵심: 요일과 시간이 일치할 때마다 반복
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          // Payload: id|duration|hour|minute
          payload: "$alarmId|$duration|$hour|$minute",
        );
        print("[반복 예약] ID: $uniqueId (요일: $weekday)");
      }
    }
    // B. 일회성 알람 (Weekdays가 비어있는 경우)
    else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmId, // 1회성은 원래 ID 그대로 사용
        title,
        body,
        _nextInstanceOneShot(hour, minute),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // 반복 없음
        // Payload: id|duration|hour|minute
        payload: "$alarmId|$duration|$hour|$minute",
      );
      print("[단발 예약] ID: $alarmId");
    }
  }

  // 4. 알람 취소
  Future<void> cancelAlarm(int alarmId, {List<int> weekdays = const []}) async {
    // 1회성 알람 취소
    await flutterLocalNotificationsPlugin.cancel(alarmId);

    // 반복 알람이 설정되어 있었다면, 파생된 ID들도 모두 취소해야 함
    // (weekdays 리스트를 모를 경우를 대비해 1~7 모두 시도하거나,
    //  Provider에서 정확한 리스트를 넘겨줘야 함. 여기서는 안전하게 1~7 모두 취소 시도)
    for (int i = 1; i <= 7; i++) {
      int uniqueId = _generateUniqueId(alarmId, i);
      await flutterLocalNotificationsPlugin.cancel(uniqueId);
    }

    print("[취소 완료] Main ID: $alarmId 및 관련 반복 알람");
  }

  // --- Helper Methods ---

  // 요일별 반복 알람을 위한 다음 시간 계산
  tz.TZDateTime _nextInstanceOfDay(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 1. 해당 요일이 될 때까지 하루씩 더함
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 2. 만약 계산된 시간이 이미 지났다면 1주일 뒤로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  // 일회성 알람을 위한 다음 시간 계산
  tz.TZDateTime _nextInstanceOneShot(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 지났으면 내일로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ID 생성 규칙 (충돌 방지용 단순 로직)
  int _generateUniqueId(int alarmId, int weekday) {
    // hashCode가 음수일 수 있으므로 절대값 처리 후 조합하거나,
    // 문자열 결합 후 다시 해시하는 방식 등을 고려할 수 있음.
    // 여기서는 간단히 문자열로 붙여서 다시 해시화 (충돌 최소화)
    return "${alarmId}_$weekday".hashCode;
  }
}
