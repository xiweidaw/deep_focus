import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../timeline/models/daily_summary.dart';

class DailyReviewScreen extends StatefulWidget {
  // 新增：允许传入目标日期（用于补写）
  final DateTime? targetDate; 

  const DailyReviewScreen({super.key, this.targetDate});

  @override
  State<DailyReviewScreen> createState() => _DailyReviewScreenState();
}

class _DailyReviewScreenState extends State<DailyReviewScreen> {
  final TextEditingController _textController = TextEditingController();
  
  int _totalMinutes = 0;
  int _totalSessions = 0;
  String _dateString = "";
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    // 如果没有传入日期，则默认为今天
    _currentDate = widget.targetDate ?? DateTime.now();
    _calculateStats();
    
    // 如果已有日记，回填进去（方便修改）
    final existing = StorageService.getSummaryByDate(_currentDate);
    if (existing != null) {
      _textController.text = existing.userSummary;
    }
  }

  void _calculateStats() {
    // 获取 目标日期 的数据，而不是永远只获取 Today
    final records = StorageService.getRecordsByDate(_currentDate);
    setState(() {
      _totalSessions = records.length;
      _totalMinutes = records.fold(0, (sum, item) => sum + item.durationMinutes);
      _dateString = DateFormat('yyyy.MM.dd').format(_currentDate);
    });
  }

  void _saveAndClose() async {
    if (_textController.text.trim().isEmpty) return;

    final summary = DailySummary(
      id: DateFormat('yyyy-MM-dd').format(_currentDate), // 使用目标日期作为 ID
      date: _currentDate,
      totalMinutes: _totalMinutes,
      totalTasks: _totalSessions,
      userSummary: _textController.text,
    );

    await StorageService.saveDailySummary(summary);

    if(!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("记录已归档"), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: subTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 数据卡片
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  boxShadow: isDark ? null : [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateString,
                      style: TextStyle(fontFamily: 'Courier', fontSize: 14, color: subTextColor?.withValues(alpha: 0.6), letterSpacing: 2),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _buildStatItem(context, "$_totalMinutes", "分钟专注"),
                        Container(width: 1, height: 40, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _buildStatItem(context, "$_totalSessions", "次任务", alignRight: true),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(height: 2, width: 40, color: AppTheme.accentColor), 
                    const SizedBox(height: 10),
                    Text(
                      "Data captured.",
                      style: TextStyle(fontFamily: 'Courier', fontSize: 10, color: subTextColor?.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Text(
                "如果用一句话总结这一天，\n你会说什么？",
                style: theme.textTheme.headlineSmall?.copyWith(color: textColor, height: 1.5, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _textController,
                style: TextStyle(fontSize: 18, color: textColor),
                cursorColor: AppTheme.accentColor,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "写点什么...",
                  hintStyle: TextStyle(color: subTextColor?.withValues(alpha: 0.2)),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: subTextColor!.withValues(alpha: 0.1))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor)),
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: TextButton(
                  onPressed: _saveAndClose,
                  child: Text(
                    "归 档",
                    style: TextStyle(letterSpacing: 4, color: subTextColor?.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String num, String label, {bool alignRight = false}) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(num, style: TextStyle(fontSize: 60, fontFamily: 'Courier', color: textColor, height: 1.0)),
        Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
      ],
    );
  }
}
