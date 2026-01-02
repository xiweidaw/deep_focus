// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusRecordAdapter extends TypeAdapter<FocusRecord> {
  @override
  final int typeId = 0;

  @override
  FocusRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusRecord(
      id: fields[0] as String,
      taskTitle: fields[1] as String,
      endTime: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      colorValue: fields[4] as int,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskTitle)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
