import 'package:hive/hive.dart';

part 'daily_summary.g.dart';

@HiveType(typeId: 1) // 注意：之前的 FocusRecord 是 0，这里必须是 1
class DailySummary extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int totalMinutes;

  @HiveField(3)
  final int totalTasks;

  @HiveField(4)
  final String userSummary; // 用户写的那一句话

  DailySummary({
    required this.id,
    required this.date,
    required this.totalMinutes,
    required this.totalTasks,
    required this.userSummary,
  });
}
