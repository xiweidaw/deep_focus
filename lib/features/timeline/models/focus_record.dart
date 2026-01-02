import 'dart:ui';
import 'package:hive/hive.dart';

part 'focus_record.g.dart';

@HiveType(typeId: 0)
class FocusRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskTitle;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final int colorValue;

  @HiveField(5) // 新增字段
  String? note; // 允许为空，且不是 final，方便修改

  FocusRecord({
    required this.id,
    required this.taskTitle,
    required this.endTime,
    required this.durationMinutes,
    required this.colorValue,
    this.note,
  });

  Color get categoryColor => Color(colorValue);
}
