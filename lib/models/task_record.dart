import 'package:hive/hive.dart';

part 'task_record.g.dart'; // 等待生成的文件

@HiveType(typeId: 0) // 确保 typeId 唯一
class TaskRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 任务类型：阅读、写作等

  @HiveField(2)
  final int duration; // 专注时长（秒）

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final String note; // 复盘心得

  @HiveField(5)
  final String rating; // 状态评价

  TaskRecord({
    required this.id,
    required this.type,
    required this.duration,
    required this.startTime,
    required this.note,
    required this.rating,
  });
}
