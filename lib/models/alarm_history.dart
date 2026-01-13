import 'package:hive/hive.dart';

part 'alarm_history.g.dart';

@HiveType(typeId: 2) // TypeId 0: Alarm, 1: MissionType (if exists), 2: History
class AlarmHistory extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final int scheduledHour;

  @HiveField(3)
  final int scheduledMinute;

  @HiveField(4)
  final String characterName;

  @HiveField(5) // Store color as int value (ARGB)
  final int characterColorValue;

  AlarmHistory({
    required this.timestamp,
    required this.score,
    required this.scheduledHour,
    required this.scheduledMinute,
    required this.characterName,
    required this.characterColorValue,
    this.imagePath = '', // Default to empty if not present
  });

  @HiveField(6, defaultValue: '')
  final String imagePath;
}
