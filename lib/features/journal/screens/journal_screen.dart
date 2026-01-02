import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart'; // 引入
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/storage_service.dart';
import '../../timeline/models/focus_record.dart';
import '../../timeline/models/daily_summary.dart';
import '../../timeline/widgets/timeline_tile.dart'; 
import '../widgets/journal_card.dart';
import '../widgets/week_calendar_header.dart'; // 引入新组件
import '../../home/screens/daily_review_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now(); // 用于控制日历翻页

  // 检查某天是否有数据 (用于显示小圆点)
  bool _hasDataOnDate(DateTime date) {
    // 简单检查：看 DailyBox 或 TaskBox 里有没有这一天的 Key/Record
    // 注意：如果是大量数据，这种遍历可能会慢，优化方案是维护一个 Set<String> activeDates
    // MVP阶段直接查：
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final hasSummary = StorageService.getDailyBox().containsKey(dateKey);
    if (hasSummary) return true;

    final hasRecord = StorageService.getTaskBox().values.any((r) => 
      r.endTime.year == date.year && 
      r.endTime.month == date.month && 
      r.endTime.day == date.day
    );
    return hasRecord;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          DateFormat('yyyy年 MM月').format(_focusedDate), // 标题显示当前月份
          style: TextStyle(
            letterSpacing: 2, 
            fontSize: 16, 
            color: theme.textTheme.bodyLarge?.color,
            fontFamily: 'Noto Serif SC', // 宋体
            fontWeight: FontWeight.bold
          )
        ),
        // 保留回到今天的按钮
        actions: [
          IconButton(
            icon: const Icon(Icons.today, size: 20),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<DailySummary>>(
        valueListenable: StorageService.listenToSummaries(),
        builder: (context, summaryBox, _) {
          return ValueListenableBuilder<Box<FocusRecord>>(
            valueListenable: StorageService.listenToRecords(),
            builder: (context, recordBox, _) {
              
              // 获取当前选中天的数据
              final summary = StorageService.getSummaryByDate(_selectedDate);
              final records = StorageService.getRecordsByDate(_selectedDate);
              
              return Column(
                children: [
                  // --- 1. 周历头部 ---
                  Container(
                    color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WeekCalendarHeader(
                      selectedDate: _selectedDate,
                      focusedDate: _focusedDate,
                      hasEvent: _hasDataOnDate,
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDate = selected;
                          _focusedDate = focused;
                        });
                      },
                    ),
                  ),

                  // --- 2. 下方内容区域 (可滚动) ---
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 显示具体选中的日期文本 (如: 12月28日 · 周日)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            child: Text(
                              _getFullDateStr(_selectedDate),
                              style: TextStyle(
                                fontFamily: 'Noto Serif SC',
                                fontSize: 24,
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // A. 日记卡片
                          if (summary != null)
                            JournalCard(summary: summary)
                          else 
                            _buildAddSummaryButton(context),

                          const SizedBox(height: 30),

                          // B. 时间轴
                          if (records.isEmpty) 
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                  "此处留白。",
                                  style: TextStyle(color: theme.disabledColor.withValues(alpha: 0.3), fontFamily: 'Noto Serif SC'),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: records.asMap().entries.map((entry) {
                                return TimelineTile(
                                  record: entry.value,
                                  isFirst: entry.key == 0,
                                  isLast: entry.key == records.length - 1,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddSummaryButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => DailyReviewScreen(targetDate: _selectedDate))
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 24),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                "补写日记",
                style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor, fontFamily: 'Noto Serif SC'),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getFullDateStr(DateTime date) {
    // 格式化为 "12月28日 · 周日"
    final dateRes = DateFormat('MM月dd日').format(date);
    final weekRes = _weakdayChinese(date.weekday);
    return "$dateRes · $weekRes";
  }

  String _weakdayChinese(int weekday) {
    return ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][weekday - 1];
  }
}
