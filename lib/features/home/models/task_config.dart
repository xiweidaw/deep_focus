import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task_config.g.dart';

@HiveType(typeId: 2) // 分配 typeId 2
class TaskConfig extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int defaultMinutes;

  @HiveField(3)
  int colorValue; // 存储颜色的整数值

  TaskConfig({
    required this.id,
    required this.title,
    required this.defaultMinutes,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}
