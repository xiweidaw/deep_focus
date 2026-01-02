import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // 必须引入 intl
import '../../features/timeline/models/focus_record.dart';
import '../../features/timeline/models/daily_summary.dart';
import '../../features/home/models/task_config.dart';
import '../theme/app_theme.dart';

class StorageService {
  static const String taskBoxName = 'focus_records';
  static const String dailyBoxName = 'daily_summaries';
  static const String configBoxName = 'task_configs';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FocusRecordAdapter());
    Hive.registerAdapter(DailySummaryAdapter()); 
    Hive.registerAdapter(TaskConfigAdapter());
    
    await Hive.openBox<FocusRecord>(taskBoxName);
    await Hive.openBox<DailySummary>(dailyBoxName);
    await Hive.openBox<TaskConfig>(configBoxName);
    await Hive.openBox<bool>(settingsBoxName);
    
    await _seedDefaultTasks();
  }

  static Box<T> getBox<T>(String name) => Hive.box<T>(name);

  // --- Task Config ---
  static Box<TaskConfig> getConfigBox() => Hive.box<TaskConfig>(configBoxName);
  static ValueListenable<Box<TaskConfig>> listenToConfigs() => getConfigBox().listenable();
  static Future<void> saveTaskConfig(TaskConfig config) async => await getConfigBox().put(config.id, config);
  static Future<void> deleteTaskConfig(String id) async => await getConfigBox().delete(id);
  
  static Future<void> _seedDefaultTasks() async {
    final box = getConfigBox();
    if (box.isEmpty) {
      final defaultTasks = [
        TaskConfig(id: '1', title: '深度阅读', defaultMinutes: 45, colorValue: AppTheme.taskColors[0].value),
        TaskConfig(id: '2', title: '专注写作', defaultMinutes: 60, colorValue: AppTheme.taskColors[1].value),
        TaskConfig(id: '3', title: '冥想', defaultMinutes: 15, colorValue: AppTheme.taskColors[2].value),
        TaskConfig(id: '4', title: '单词记忆', defaultMinutes: 30, colorValue: AppTheme.taskColors[3].value),
      ];
      for (var task in defaultTasks) await box.put(task.id, task);
    }
  }

  // --- Focus Record ---
  static Box<FocusRecord> getTaskBox() => Hive.box<FocusRecord>(taskBoxName);
  static Future<void> saveRecord(FocusRecord record) async => await getTaskBox().add(record);
  static ValueListenable<Box<FocusRecord>> listenToRecords() => getTaskBox().listenable();
  static List<FocusRecord> getTodayRecords() => getRecordsByDate(DateTime.now());

  // 🔥 新增：根据日期获取专注记录
  static List<FocusRecord> getRecordsByDate(DateTime date) {
    final box = getTaskBox();
    return box.values.where((r) => 
      r.endTime.year == date.year && 
      r.endTime.month == date.month && 
      r.endTime.day == date.day
    ).toList()..sort((a, b) => b.endTime.compareTo(a.endTime)); // 倒序
  }
  
  // --- Daily Summary ---
  static Box<DailySummary> getDailyBox() => Hive.box<DailySummary>(dailyBoxName);
  static Future<void> saveDailySummary(DailySummary summary) async => await getDailyBox().put(summary.id, summary);
  static ValueListenable<Box<DailySummary>> listenToSummaries() => getDailyBox().listenable();
  
  // 🔥 新增：根据日期获取日记 (Key 格式为 yyyy-MM-dd)
  static DailySummary? getSummaryByDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return getDailyBox().get(key);
  }
}
