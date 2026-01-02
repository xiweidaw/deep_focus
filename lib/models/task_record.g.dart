// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskRecordAdapter extends TypeAdapter<TaskRecord> {
  @override
  final int typeId = 0;

  @override
  TaskRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskRecord(
      id: fields[0] as String,
      type: fields[1] as String,
      duration: fields[2] as int,
      startTime: fields[3] as DateTime,
      note: fields[4] as String,
      rating: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TaskRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
