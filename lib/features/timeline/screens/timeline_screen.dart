import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/focus_record.dart';
import '../widgets/timeline_tile.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取当前的主题颜色
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "历史记录", // 汉化
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: subTextColor?.withValues(alpha: 0.5), // 动态颜色
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "回顾你的\n专注旅程。", // 汉化
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      // color 属性会自动跟随 Theme 中的 textTheme 定义，无需手动指定
                    ),
                  ),
                ],
              ),
            ),

            // Real Data List
            Expanded(
              child: ValueListenableBuilder<Box<FocusRecord>>(
                valueListenable: StorageService.listenToRecords(),
                builder: (context, box, _) {
                  final records = box.values.toList();
                  records.sort((a, b) => b.endTime.compareTo(a.endTime));

                  if (records.isEmpty) {
                    return Center(
                      child: Text(
                        "暂无记录\n开始你的第一次专注吧。", // 汉化
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subTextColor?.withValues(alpha: 0.3),
                          height: 1.5
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: records.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 80, bottom: 20, top: 10),
                          child: Text(
                            "TIMELINE", // 保持英文大写作为装饰，或者改成 “时间轴”
                            style: TextStyle(
                              color: AppTheme.accentColor, // 使用新的青蓝色
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        );
                      }

                      final recordIndex = index - 1;
                      final record = records[recordIndex];

                      return TimelineTile(
                        record: record,
                        isFirst: recordIndex == 0,
                        isLast: recordIndex == records.length - 1,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
