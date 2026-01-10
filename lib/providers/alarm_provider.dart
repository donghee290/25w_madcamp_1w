import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/alarm_model.dart';
import '../services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  // main.dart에서 미리 openBox로 열어둔 box를 참조
  final Box<Alarm> _alarmBox = Hive.box<Alarm>('alarmBox');

  /// Hive에 저장된 알람을 List로 변환하고, 시간 순서(오전->오후)로 정렬하여 반환
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

  Future<void> addAlarm(Alarm alarm) async {
    await _alarmBox.put(alarm.id, alarm);
    notifyListeners();

    if (alarm.isEnabled) {
      DateTime nextTime = _calculateNextRingTime(alarm);
      await NotificationService().scheduleAlarm(
        id: alarm.id.hashCode,
        title: alarm.label,
        body: "알람이 설정되었습니다.",
        scheduledTime: nextTime,
      );
    }
  }

  Future<void> deleteAlarm(String id) async {
    await NotificationService().cancelAlarm(id.hashCode);
    await _alarmBox.delete(id);
    notifyListeners();
  }

  Future<void> updateAlarm(Alarm updatedAlarm) async {
    await _alarmBox.put(updatedAlarm.id, updatedAlarm);
    notifyListeners();

    if (updatedAlarm.isEnabled) {
      DateTime nextTime = _calculateNextRingTime(updatedAlarm);

      await NotificationService().scheduleAlarm(
        id: updatedAlarm.id.hashCode,
        title: updatedAlarm.label.isEmpty ? "알람" : updatedAlarm.label,
        body: "기상 시간입니다!",
        scheduledTime: nextTime,
      );
    } else {
      await NotificationService().cancelAlarm(updatedAlarm.id.hashCode);
    }
  }

  /// 현재 시간과 설정된 요일을 고려하여 가장 가까운 다음 알람 시각을 계산
  DateTime _calculateNextRingTime(Alarm alarm) {
    final now = DateTime.now();
    DateTime targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.hour,
      alarm.minute,
    );

    // 1. 반복 요일이 없는 경우 (일회성)
    // 이미 시간이 지났으면 내일로 설정
    if (alarm.weekdays.isEmpty) {
      if (targetTime.isBefore(now)) {
        return targetTime.add(const Duration(days: 1));
      }
      return targetTime;
    }

    // 2. 반복 요일이 있는 경우
    // 오늘부터 1주일을 순회하며 설정된 요일 중 가장 가까운 날짜를 탐색
    for (int i = 0; i < 8; i++) {
      DateTime checkDate = targetTime.add(Duration(days: i));
      // 오늘 날짜인데 이미 시간이 지난 경우
      if (i == 0 && checkDate.isBefore(now)) {
        continue;
      }
      if (alarm.weekdays.contains(checkDate.weekday)) {
        return checkDate;
      }
    }

    // 안전 장치 (논리적으로 도달 불가하나 컴파일러를 위해 반환)
    return targetTime.add(const Duration(days: 1));
  }
}
