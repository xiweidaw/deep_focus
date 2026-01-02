// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailySummaryAdapter extends TypeAdapter<DailySummary> {
  @override
  final int typeId = 1;

  @override
  DailySummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySummary(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      totalMinutes: fields[2] as int,
      totalTasks: fields[3] as int,
      userSummary: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailySummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalMinutes)
      ..writeByte(3)
      ..write(obj.totalTasks)
      ..writeByte(4)
      ..write(obj.userSummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
