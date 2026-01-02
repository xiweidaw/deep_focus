import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/storage_service.dart';
import '../../timeline/models/focus_record.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return ValueListenableBuilder<Box<FocusRecord>>(
      valueListenable: StorageService.listenToRecords(),
      builder: (context, box, _) {
        final records = box.values.toList();
        
        // 1. 基础统计
        final totalMinutes = records.fold<int>(0, (sum, item) => sum + item.durationMinutes);
        final totalHours = (totalMinutes / 60).toStringAsFixed(1);
        final totalSessions = records.length.toString();

        // 2. 真正的 Streak 算法
        final streak = _calculateStreak(records);

        // 3. 准备周视图数据
        final now = DateTime.now();
        final List<Map<String, dynamic>> weekData = [];
        
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          // 仅比较年月日
          final dayRecords = records.where((r) => 
            r.endTime.year == date.year && 
            r.endTime.month == date.month && 
            r.endTime.day == date.day
          ).toList();
          
          final dayMinutes = dayRecords.fold<int>(0, (sum, r) => sum + r.durationMinutes);
          
          weekData.add({
            'dayLabel': _getWeekdayLabel(date.weekday),
            'minutes': dayMinutes,
            'isToday': i == 0,
          });
        }

        final maxMinutes = weekData.map((e) => e['minutes'] as int).reduce((a, b) => a > b ? a : b);
        final maxScale = maxMinutes == 0 ? 1 : maxMinutes;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor, 
            borderRadius: BorderRadius.circular(20),
            boxShadow: Theme.of(context).brightness == Brightness.light 
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))] 
              : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(totalHours, "小时", textColor, subTextColor),
                  _buildVerticalDivider(context),
                  _buildStatItem(totalSessions, "次专注", textColor, subTextColor),
                  _buildVerticalDivider(context),
                  _buildStatItem("$streak", "天连胜", textColor, subTextColor), // 显示真数据
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekData.map((data) {
                  final double heightRatio = (data['minutes'] as int) / maxScale;
                  final double uiHeight = heightRatio == 0 ? 0.05 : heightRatio; 
                  return _buildBar(context, uiHeight, data['dayLabel'], isActive: data['minutes'] > 0 || data['isToday']);
                }).toList(),
              )
            ],
          ),
        );
      }
    );
  }

  // 计算连胜天数
  int _calculateStreak(List<FocusRecord> records) {
    if (records.isEmpty) return 0;

    // 1. 提取所有有记录的日期 (去重)
    final uniqueDates = records.map((r) {
      return DateTime(r.endTime.year, r.endTime.month, r.endTime.day);
    }).toSet().toList();
    
    // 2. 排序 (最近的在前面)
    uniqueDates.sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    // 3. 检查最新的记录是否是今天或昨天
    // 如果最新的记录比昨天还早，说明断签了，streak归零
    if (uniqueDates.first.isBefore(yesterday)) {
      return 0;
    }

    // 4. 开始计数
    int streak = 1;
    DateTime checkDate = uniqueDates.first; // 可能是今天，也可能是昨天

    for (int i = 1; i < uniqueDates.length; i++) {
      final prevDate = uniqueDates[i];
      // 如果前一条记录的日期 == checkDate - 1天，说明连续
      if (prevDate.year == checkDate.subtract(const Duration(days: 1)).year &&
          prevDate.month == checkDate.subtract(const Duration(days: 1)).month &&
          prevDate.day == checkDate.subtract(const Duration(days: 1)).day) {
        streak++;
        checkDate = prevDate;
      } else {
        break; // 不连续，停止
      }
    }
    return streak;
  }
  
  // ... 其他 Helper Methods (_getWeekdayLabel, _buildStatItem 等) 保持不变 ...
  // 为了篇幅，请保留原文件下方的 Helper Methods。
  // 必须把原文件下方的 _getWeekdayLabel, _buildStatItem, _buildVerticalDivider, _buildBar 复制过来
  // 或者只替换 build 方法和 新增 _calculateStreak 方法。
  
  String _getWeekdayLabel(int weekday) {
    const labels = ["一", "二", "三", "四", "五", "六", "日"];
    return labels[weekday - 1];
  }

  Widget _buildStatItem(String number, String label, Color? numColor, Color? labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(number, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Courier', color: numColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: labelColor?.withValues(alpha: 0.6), letterSpacing: 1)),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(height: 30, width: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.2));
  }

  Widget _buildBar(BuildContext context, double value, String day, {bool isActive = false}) {
     final inactiveColor = Theme.of(context).disabledColor.withValues(alpha: 0.2);
     final activeTextColor = Theme.of(context).textTheme.bodyLarge?.color;
     final inactiveTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      children: [
        Container(
          width: 8,
          height: (60 * value).clamp(4.0, 60.0), 
          decoration: BoxDecoration(color: isActive ? AppTheme.accentColor : inactiveColor, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? activeTextColor : inactiveTextColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
