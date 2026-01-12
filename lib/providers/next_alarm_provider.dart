import 'dart:async';
import 'package:flutter/foundation.dart';
import 'alarm_provider.dart';
import '../models/alarm_model.dart';

class NextAlarmProvider extends ChangeNotifier {
  AlarmProvider? _alarmProvider;
  Timer? _ticker;

  DateTime? _next;
  String _label = '알람이 없습니다.';

  String get label => _label;
  DateTime? get nextDateTime => _next;

  void setAlarmProvider(AlarmProvider alarmProvider) {
    _alarmProvider?.removeListener(_recalculate);

    _alarmProvider = alarmProvider;
    _alarmProvider!.addListener(_recalculate);

    _recalculate();
    _startMinuteTicker();
  }

  void _startMinuteTicker() {
    _ticker?.cancel();

    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    final initialDelay = nextMinute.difference(now);

    _ticker = Timer(initialDelay, () {
      _recalculate(); //분 경계 첫 갱신

      _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
        _recalculate(); //이후 매 분 갱신
      });
    });
  }

  void _recalculate() {
    final ap = _alarmProvider;
    if (ap == null) return;

    final now = DateTime.now();

    DateTime? nearest;

    for (final alarm in ap.alarms) {
      if (!alarm.isEnabled) continue;

      final dt = _nextOccurrence(alarm, now);
      if (dt == null) continue;

      if (nearest == null || dt.isBefore(nearest)) {
        nearest = dt;
      }
    }

    _next = nearest;
    _label = _buildLabel(nearest, now);

    notifyListeners();
  }

  DateTime? _nextOccurrence(Alarm alarm, DateTime now) {
    final allowed = alarm.weekdays; //빈 리스트면 매일로 취급

    for (int addDays = 0; addDays <= 7; addDays++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: addDays));
      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        alarm.hour,
        alarm.minute,
      );

      if (!candidate.isAfter(now)) continue;

      final isAllowed = allowed.isEmpty || allowed.contains(candidate.weekday);
      if (!isAllowed) continue;

      return candidate;
    }

    return null;
  }

  String _buildLabel(DateTime? next, DateTime now) {
    if (next == null) return '예정된 기상 없음';

    final diff = next.difference(now);
    final totalMinutes = diff.isNegative ? 0 : ((diff.inSeconds + 59) ~/ 60);

    final days = totalMinutes ~/ (60 * 24);
    final hours = (totalMinutes % (60 * 24)) ~/ 60;
    final minutes = totalMinutes % 60;

    if (totalMinutes == 0) return '곧 기상이다.';

    if (days > 0) {
      if (minutes == 0) return '$days일 $hours시간 뒤 기상이다.';
      return '$days일 $hours시간 $minutes분 뒤 기상이다.';
    }

    if (hours > 0) {
      if (minutes == 0) return '$hours시간 뒤 기상이다.';
      return '$hours시간 $minutes분 뒤 기상이다.';
    }

    return '$minutes분 뒤 기상이다.';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _alarmProvider?.removeListener(_recalculate);
    super.dispose();
  }
}
