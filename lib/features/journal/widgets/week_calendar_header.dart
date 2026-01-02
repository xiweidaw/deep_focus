import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_theme.dart';

class WeekCalendarHeader extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final Function(DateTime, DateTime) onDaySelected;
  final bool Function(DateTime) hasEvent; // 用于判断某天是否有数据（显示小圆点）

  const WeekCalendarHeader({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.onDaySelected,
    required this.hasEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = AppTheme.accentColor;

    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDate,
      currentDay: DateTime.now(), // 标记今天
      
      // 核心配置：周视图，高度自适应
      calendarFormat: CalendarFormat.week,
      headerVisible: false, // 隐藏自带的 Header，我们自己已经在上面写了
      daysOfWeekVisible: true, // 显示周一、周二...
      
      // 选中逻辑
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: onDaySelected,

      // 事件标记逻辑 (小圆点)
      eventLoader: (day) {
        // 如果这天有数据，返回一个非空List，Calendar会自动画标记
        return hasEvent(day) ? [true] : []; 
      },

      // --- 样式定制 (Styling) ---
      calendarStyle: CalendarStyle(
        // 字体统一
        defaultTextStyle: TextStyle(fontFamily: 'Courier', color: theme.textTheme.bodyLarge?.color),
        weekendTextStyle: TextStyle(fontFamily: 'Courier', color: theme.textTheme.bodyLarge?.color),
        
        // 今天 (未被选中时)
        todayTextStyle: const TextStyle(color: AppTheme.accentColor, fontFamily: 'Courier', fontWeight: FontWeight.bold),
        todayDecoration: BoxDecoration(
          border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5)),
          shape: BoxShape.circle,
        ),

        // 选中日期 (高亮)
        selectedTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.accentColor,
          shape: BoxShape.circle,
        ),

        // 小圆点样式
        markerDecoration: BoxDecoration(
          color: theme.disabledColor.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        markerSize: 4,
        markerMargin: const EdgeInsets.only(top: 4),
      ),

      // 周几的样式 (Mon, Tue)
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color, fontFamily: 'Noto Serif SC'),
        weekendStyle: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color, fontFamily: 'Noto Serif SC'),
      ),
    );
  }
}
