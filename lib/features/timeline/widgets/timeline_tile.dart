import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/focus_record.dart';

class TimelineTile extends StatelessWidget {
  final FocusRecord record;
  final bool isFirst;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.record,
    this.isFirst = false,
    this.isLast = false,
  });

  // 编辑心得
  void _showEditNoteDialog(BuildContext context) {
    // ... 代码不变，为了节省篇幅，这里略过，请保持原样 ...
    final controller = TextEditingController(text: record.note);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          title: Text("专注心得", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 1, maxLines: 5,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16, height: 1.5),
            decoration: InputDecoration(
              hintText: "这次专注有什么收获...",
              hintStyle: TextStyle(color: theme.disabledColor.withValues(alpha: 0.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("取消", style: TextStyle(color: theme.disabledColor)),
            ),
            TextButton(
              onPressed: () {
                record.note = controller.text.trim();
                record.save(); 
                Navigator.pop(context);
              },
              child: const Text("保存", style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 🔥 新增：删除确认弹窗
  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("删除记录", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: Text("确定要抹去这段专注时光吗？", style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("取消", style: TextStyle(color: theme.disabledColor)),
          ),
          TextButton(
            onPressed: () {
              record.delete(); // HiveObject 自带的删除方法
              Navigator.pop(context);
            },
            child: const Text("删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 动态样式
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final lineColor = Theme.of(context).dividerColor.withValues(alpha: 0.1); 

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 左侧时间
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                DateFormat('HH:mm').format(record.endTime),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: subTextColor?.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // 2. 中间轴线
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: EdgeInsets.only(top: isFirst ? 30 : 0, bottom: isLast ? 30 : 0),
                  width: 1, 
                  color: lineColor,
                ),
                Positioned(
                  top: 24, 
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: record.categoryColor, width: 2),
                      boxShadow: [
                         BoxShadow(color: record.categoryColor.withValues(alpha: 0.5), blurRadius: 8)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. 右侧内容 (新增：onLongPress 删除)
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditNoteDialog(context), // 点击编辑
              onLongPress: () => _showDeleteDialog(context), // 🔥 长按删除
              child: Container(
                color: Colors.transparent, 
                padding: const EdgeInsets.fromLTRB(10, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.taskTitle,
                      style: TextStyle(fontSize: 18, color: titleColor, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${record.durationMinutes} 分钟",
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    
                    if (record.note != null && record.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: record.categoryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          record.note!,
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor?.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
