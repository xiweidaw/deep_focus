import 'package:flutter/material.dart';
import '../../timeline/models/daily_summary.dart';
import '../../home/screens/daily_review_screen.dart'; // 引入编辑页

class JournalCard extends StatelessWidget {
  final DailySummary summary;

  const JournalCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9);
    final quoteColor = theme.primaryColor.withValues(alpha: 0.5);

    // 🔥 包裹 GestureDetector 实现点击编辑
    return GestureDetector(
      onTap: () {
        // 跳转到 DailyReviewScreen，这是目前保存/编辑日记的统一入口
        // 因为我们在 DailyReviewScreen 中已经实现了“读取旧数据”的逻辑 (getSummaryByDate)
        // 只要传入正确的 targetDate，它就会自己填充内容，最后保存时覆盖旧数据
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyReviewScreen(targetDate: summary.date),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote, size: 32, color: quoteColor),
            const SizedBox(height: 12),
            Text(
              summary.userSummary,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6, 
                fontSize: 16,
                fontFamily: 'Noto Serif SC', 
                fontStyle: FontStyle.normal, 
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildTag(context, "${summary.totalMinutes} 分钟专注"),
                const SizedBox(width: 12),
                _buildTag(context, "${summary.totalTasks} 次任务"),
                const Spacer(),
                Icon(Icons.edit, size: 12, color: theme.disabledColor.withValues(alpha: 0.3)), // 小编辑图标提示
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
