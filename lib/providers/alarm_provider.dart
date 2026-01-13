import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/alarm_model.dart';
import '../services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  // Hive Box 참조
  final Box<Alarm> _alarmBox = Hive.box<Alarm>('alarmBox');

  // 캐시된 정렬 리스트
  List<Alarm> _sortedAlarms = [];

  AlarmProvider() {
    _initializeAlarms();
  }

  void _initializeAlarms() {
    _sortedAlarms = _alarmBox.values.toList();
    _sortAllAlarms();
  }

  /// 전체 재정렬 (초기화용)
  void _sortAllAlarms() {
    _sortedAlarms.sort((a, b) => _compareAlarms(a, b));
  }

  /// 정렬 비교 로직
  int _compareAlarms(Alarm a, Alarm b) {
    // 1. 활성화 상태 (ON -> OFF 순서)
    if (a.isEnabled != b.isEnabled) {
      return a.isEnabled ? -1 : 1;
    }
    // 2. 다음 알람 시간 (가까운 순서)
    final nextA = _calculateNextTriggerTime(a);
    final nextB = _calculateNextTriggerTime(b);
    return nextA.compareTo(nextB);
  }

  DateTime _calculateNextTriggerTime(Alarm alarm) {
    final now = DateTime.now();
    if (alarm.weekdays.isEmpty) {
      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.hour,
        alarm.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    } else {
      DateTime? closest;
      for (var weekday in alarm.weekdays) {
        var d = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.hour,
          alarm.minute,
        );
        
        int diff = weekday - now.weekday;
        if (diff < 0) {
          d = d.add(Duration(days: diff + 7));
        } else if (diff > 0) {
          d = d.add(Duration(days: diff));
        } else {
          if (d.isBefore(now)) {
            d = d.add(const Duration(days: 7));
          }
        }

        if (closest == null || d.isBefore(closest)) {
          closest = d;
        }
      }
      return closest ?? DateTime(now.year + 1);
    }
  }

  /// 캐시된 정렬 리스트 반환 (O(1))
  List<Alarm> get alarms => List.unmodifiable(_sortedAlarms);

  /// 중복 시간 확인 (활성화된 알람 기준)
  bool hasDuplicateAlarm(int hour, int minute) {
    return _alarmBox.values.any(
      (alarm) =>
          alarm.isEnabled && alarm.hour == hour && alarm.minute == minute,
    );
  }

  /// 알람 추가 (O(N))
  Future<void> addAlarm(Alarm alarm) async {
    await _alarmBox.put(alarm.id, alarm);
    
    // 정렬된 위치에 삽입
    _insertAlarmSorted(alarm);
    
    notifyListeners();

    if (alarm.isEnabled) {
      await _scheduleNotification(alarm);
    }
  }

  /// 알람 삭제 (O(N))
  Future<void> deleteAlarm(String id) async {
    await NotificationService().cancelAlarm(id.hashCode);
    await _alarmBox.delete(id);
    
    _sortedAlarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  /// 알람 수정 (O(N))
  Future<void> updateAlarm(Alarm updatedAlarm) async {
    await _alarmBox.put(updatedAlarm.id, updatedAlarm);
    
    // 리스트에서 기존 항목 제거 후 새 항목 삽입
    _sortedAlarms.removeWhere((a) => a.id == updatedAlarm.id);
    _insertAlarmSorted(updatedAlarm);
    
    notifyListeners();

    // 1. 기존 알람 취소
    await NotificationService().cancelAlarm(updatedAlarm.id.hashCode);

    // 2. 켜져있을 경우에만 재등록
    if (updatedAlarm.isEnabled) {
      await _scheduleNotification(updatedAlarm);
    }
  }

  /// 정렬 유지하며 삽입
  void _insertAlarmSorted(Alarm alarm) {
    int index = 0;
    while (index < _sortedAlarms.length) {
      if (_compareAlarms(alarm, _sortedAlarms[index]) < 0) {
        break;
      }
      index++;
    }
    _sortedAlarms.insert(index, alarm);
  }

  /// [Private Helper] 알람 등록 로직 단순화
  Future<void> _scheduleNotification(Alarm alarm) async {
    // Payload format: alarm|id|hour|minute|sound|volume|duration|snooze|missionType
    final String notificationPayload =
        "alarm|${alarm.id}|${alarm.hour}|${alarm.minute}|${alarm.soundFileName}|${alarm.volume}|${alarm.duration}|${alarm.snoozeCount}|${alarm.missionType.index}";

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
