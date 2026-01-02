// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskConfigAdapter extends TypeAdapter<TaskConfig> {
  @override
  final int typeId = 2;

  @override
  TaskConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskConfig(
      id: fields[0] as String,
      title: fields[1] as String,
      defaultMinutes: fields[2] as int,
      colorValue: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TaskConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.defaultMinutes)
      ..writeByte(3)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
