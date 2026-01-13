import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/alarm_model.dart';
import '../services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  // Hive Box 참조
  final Box<Alarm> _alarmBox = Hive.box<Alarm>('alarmBox');

  /// Hive에 저장된 알람을 List로 변환하고 정렬하여 반환
  List<Alarm> get alarms {
    final alarmsList = _alarmBox.values.toList();
    alarmsList.sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour.compareTo(b.hour);
      }
      return a.minute.compareTo(b.minute);
    });
    return alarmsList;
  }

  /// 중복 시간 확인 (활성화된 알람 기준)
  bool hasDuplicateAlarm(int hour, int minute) {
    return _alarmBox.values.any(
      (alarm) =>
          alarm.isEnabled && alarm.hour == hour && alarm.minute == minute,
    );
  }

  /// 알람 추가
  Future<void> addAlarm(Alarm alarm) async {
    await _alarmBox.put(alarm.id, alarm);
    notifyListeners();

    if (alarm.isEnabled) {
      await _scheduleNotification(alarm);
    }
  }

  /// 알람 삭제
  Future<void> deleteAlarm(String id) async {
    // 기존 예약된 알람 취소
    await NotificationService().cancelAlarm(id.hashCode);
    await _alarmBox.delete(id);
    notifyListeners();
  }

  /// 알람 수정
  Future<void> updateAlarm(Alarm updatedAlarm) async {
    await _alarmBox.put(updatedAlarm.id, updatedAlarm);
    notifyListeners();

    // 1. 기존 알람 취소
    await NotificationService().cancelAlarm(updatedAlarm.id.hashCode);

    // 2. 켜져있을 경우에만 재등록
    if (updatedAlarm.isEnabled) {
      await _scheduleNotification(updatedAlarm);
    }
  }

  /// [Private Helper] 알람 등록 로직 단순화
  Future<void> _scheduleNotification(Alarm alarm) async {
    // Payload format: alarm|id|hour|minute|sound|volume
    final String notificationPayload =
        "alarm|${alarm.id}|${alarm.hour}|${alarm.minute}|${alarm.soundFileName}|${alarm.volume}|${alarm.duration}|${alarm.snoozeCount}";

    await NotificationService().scheduleAlarm(
      alarmId: alarm.id.hashCode,
      title: alarm.label.isEmpty ? "알람" : alarm.label,
      body: "기상 시간입니다!",
      hour: alarm.hour, // 시
      minute: alarm.minute, // 분
      weekdays: alarm.weekdays, // 요일 리스트
      payload: notificationPayload,
      duration: alarm.duration,
    );
  }
}
