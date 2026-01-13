import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'alarm_model.g.dart';

@HiveType(typeId: 1)
enum MissionType {
  @HiveField(0)
  math,
  @HiveField(1)
  colors,
  @HiveField(2)
  write,
  @HiveField(3)
  shake,
}

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  bool isVibration;

  @HiveField(6)
  List<int> weekdays;

  @HiveField(7)
  MissionType missionType;

  @HiveField(8)
  int missionDifficulty;

  @HiveField(9)
  String soundFileName;

  @HiveField(10)
  int duration;

  @HiveField(11)
  int snoozeCount;

  @HiveField(12)
  String? payload;

  @HiveField(13)
  int missionCount;

  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    this.isEnabled = true,
    this.isVibration = true,
    this.weekdays = const [],
    this.missionType = MissionType.math,
    this.missionDifficulty = 1,
    this.missionCount = 2,
    this.soundFileName = 'default_alarm.mp3',
    this.duration = 5,
    this.snoozeCount = 3,
    this.payload,
  });

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  // copyWith: 바뀐 것만 덮어쓰기
  Alarm copyWith({
    String? id,
    String? label,
    int? hour,
    int? minute,
    bool? isEnabled,
    bool? isVibration,
    List<int>? weekdays,
    MissionType? missionType,
    int? missionDifficulty,
    int? missionCount,
    String? soundFileName,
    int? duration,
    int? snoozeCount,
    String? payload,
  }) {
    return Alarm(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      isVibration: isVibration ?? this.isVibration,
      weekdays: weekdays ?? List.from(this.weekdays),
      missionType: missionType ?? this.missionType,
      missionDifficulty: missionDifficulty ?? this.missionDifficulty,
      missionCount: missionCount ?? this.missionCount,
      soundFileName: soundFileName ?? this.soundFileName,
      duration: duration ?? this.duration,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      payload: payload ?? this.payload,
    );
  }

  // ---------------------------------------------------------
  // Firebase(DB) 연동
  // ---------------------------------------------------------

  factory Alarm.fromJson(Map<String, dynamic> json, String id) {
    return Alarm(
      id: id,
      label: json['label'] ?? '',
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
      isEnabled: json['isEnabled'] ?? true,
      isVibration: json['isVibration'] ?? true,
      weekdays: List<int>.from(json['weekdays'] ?? []),
      missionType: MissionType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            (json['missionType']?.toString().toUpperCase() ?? 'MATH'),
        orElse: () => MissionType.math,
      ),
      missionDifficulty: json['missionDifficulty'] ?? 1,
      missionCount: json['missionCount'] ?? 2,
      soundFileName: json['soundFileName'] ?? 'default.mp3',
      duration: json['duration'] ?? 5,
      snoozeCount: json['snoozeCount'] ?? 0,
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'isVibration': isVibration,
      'weekdays': weekdays,
      'missionType': missionType.toString().split('.').last,
      'missionDifficulty': missionDifficulty,
      'missionCount': missionCount,
      'soundFileName': soundFileName,
      'duration': duration,
      'snoozeCount': snoozeCount,
      'payload': payload,
    };
  }
}
