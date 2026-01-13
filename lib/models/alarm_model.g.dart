// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 0;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      label: fields[1] as String,
      isEnabled: fields[4] as bool,
      isVibration: fields[5] as bool,
      weekdays: (fields[6] as List).cast<int>(),
      missionType: fields[7] as MissionType,
      missionDifficulty: fields[8] as int,
      missionCount: fields[13] == null ? 2 : fields[13] as int,
      soundFileName: fields[9] as String,
      duration: fields[10] as int,
      snoozeCount: fields[11] as int,
      payload: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.isVibration)
      ..writeByte(6)
      ..write(obj.weekdays)
      ..writeByte(7)
      ..write(obj.missionType)
      ..writeByte(8)
      ..write(obj.missionDifficulty)
      ..writeByte(9)
      ..write(obj.soundFileName)
      ..writeByte(10)
      ..write(obj.duration)
      ..writeByte(11)
      ..write(obj.snoozeCount)
      ..writeByte(12)
      ..write(obj.payload)
      ..writeByte(13)
      ..write(obj.missionCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MissionTypeAdapter extends TypeAdapter<MissionType> {
  @override
  final int typeId = 1;

  @override
  MissionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MissionType.math;
      case 1:
        return MissionType.colors;
      case 2:
        return MissionType.write;
      case 3:
        return MissionType.shake;
      default:
        return MissionType.math;
    }
  }

  @override
  void write(BinaryWriter writer, MissionType obj) {
    switch (obj) {
      case MissionType.math:
        writer.writeByte(0);
        break;
      case MissionType.colors:
        writer.writeByte(1);
        break;
      case MissionType.write:
        writer.writeByte(2);
        break;
      case MissionType.shake:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
