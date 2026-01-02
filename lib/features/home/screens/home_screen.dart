import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../models/task_config.dart';
import '../widgets/task_card.dart';
import './daily_review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- Task Card 逻辑 ---
  
  // 显示时间转换 Helper
  String _formatDuration(int minutes) {
    return minutes == 0 ? "正计时" : "$minutes 分钟";
  }

  void _showTaskEditor({TaskConfig? existingTask}) {
    final isEditing = existingTask != null;
    final TextEditingController titleCtrl = TextEditingController(text: existingTask?.title ?? "");
    int duration = existingTask?.defaultMinutes ?? 45;
    int colorValue = existingTask?.colorValue ?? AppTheme.taskColors[0].value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 30, 
                left: 24, right: 24, top: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4, 
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? "编辑任务" : "新建专注", 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                      ),
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            StorageService.deleteTaskConfig(existingTask.id);
                            Navigator.pop(context);
                          },
                        )
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: "任务名称", hintText: "例如：深度思考", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  
                  // 🔥 修改滑块逻辑：最小值0，最大120
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("默认时长", style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(
                          color: Color(colorValue), 
                          fontWeight: FontWeight.bold,
                          fontFamily: duration == 0 ? 'Noto Serif SC' : 'Courier'
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: duration.toDouble(),
                    min: 0, // 0 = 正计时
                    max: 120, 
                    divisions: 24, // 0, 5, 10 ... 120 (共25格)
                    activeColor: Color(colorValue),
                    onChanged: (val) { setSheetState(() => duration = val.toInt()); },
                  ),
                  
                  const SizedBox(height: 24),
                  Text("强调色", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: AppTheme.taskColors.map((c) {
                      final isSelected = c.value == colorValue;
                      return GestureDetector(
                        onTap: () => setSheetState(() => colorValue = c.value),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(colorValue),
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty) return;

                        final newTask = TaskConfig(
                          id: existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text,
                          defaultMinutes: duration,
                          colorValue: colorValue,
                        );
                        
                        await StorageService.saveTaskConfig(newTask);
                        
                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (!isEditing) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                             _pageController.animateToPage(100, duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart);
                          });
                        }
                      },
                      child: const Text("保 存", style: TextStyle(letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showTimePicker(TaskConfig task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text("完成", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: 'Courier', 
                      ),
                    )
                  ),
                  child: CupertinoPicker(
                    itemExtent: 40,
                    // 🔥 这里的初始值逻辑要改：
                    // 如果是0，index是0；如果是5，index是1...
                    scrollController: FixedExtentScrollController(
                      initialItem: task.defaultMinutes == 0 ? 0 : (task.defaultMinutes / 5).round(),
                    ),
                    onSelectedItemChanged: (index) {
                      // index 0 -> 0 (正计时)
                      // index 1 -> 5
                      // index 2 -> 10
                      final newMinutes = index * 5;
                      task.defaultMinutes = newMinutes;
                      task.save(); 
                    },
                    // 🔥 列表生成改为 25 个
                    children: List.generate(25, (i) {
                      final min = i * 5;
                      return Center(
                        child: Text(
                          _formatDuration(min),
                          style: TextStyle(
                            // 正计时用宋体，数字用等宽
                            fontFamily: min == 0 ? 'Noto Serif SC' : null
                          ),
                        )
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "专 注", 
          style: TextStyle(
            letterSpacing: 4,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "新建专注",
            onPressed: () => _showTaskEditor(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Box<TaskConfig>>(
              valueListenable: StorageService.listenToConfigs(),
              builder: (context, box, _) {
                final tasks = box.values.toList();
                
                if (tasks.isEmpty) {
                  return Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("创建你的第一个专注任务"),
                      onPressed: () => _showTaskEditor(),
                    ),
                  );
                }

                if (_currentPage >= tasks.length) {
                  _currentPage = tasks.length > 0 ? tasks.length - 1 : 0;
                }

                return Center(
                  child: SizedBox(
                    height: 500,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: tasks.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                            } else {
                              value = index == _currentPage ? 1.0 : 0.7;
                            }
                            final curve = Curves.easeOut.transform(value);
                            return Center(
                              child: SizedBox(
                                height: curve * 500,
                                width: curve * 350,
                                child: child,
                              ),
                            );
                          },
                          child: TaskCard(
                            title: task.title,
                            badgeColor: task.color,
                            currentMinutes: task.defaultMinutes,
                            onCardTap: () {
                              if (index == _currentPage) return true;
                              _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                              return false;
                            },
                            onTimeTap: () => _showTimePicker(task),
                            onLongPress: () => _showTaskEditor(existingTask: task), 
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyReviewScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                   border: Border.all(color: Theme.of(context).dividerColor),
                   borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Icon(Icons.nightlight_round, size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "每日复盘", 
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 12, letterSpacing: 1)
                    ),
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
