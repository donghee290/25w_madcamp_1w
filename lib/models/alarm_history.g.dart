// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmHistoryAdapter extends TypeAdapter<AlarmHistory> {
  @override
  final int typeId = 2;

  @override
  AlarmHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmHistory(
      timestamp: fields[0] as DateTime,
      score: fields[1] as int,
      scheduledHour: fields[2] as int,
      scheduledMinute: fields[3] as int,
      characterName: fields[4] as String,
      characterColorValue: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.scheduledHour)
      ..writeByte(3)
      ..write(obj.scheduledMinute)
      ..writeByte(4)
      ..write(obj.characterName)
      ..writeByte(5)
      ..write(obj.characterColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
