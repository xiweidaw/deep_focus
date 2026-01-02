import 'package:flutter/material.dart';
import '../screens/focus_mode_screen.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final Color badgeColor; // 强调色
  final int currentMinutes;
  
  // 回调函数
  final bool Function() onCardTap; // 返回 true 允许进入
  final VoidCallback onTimeTap;    // 修改时间
  final VoidCallback onLongPress;  // 长按编辑

  const TaskCard({
    super.key,
    required this.title,
    required this.badgeColor,
    required this.currentMinutes,
    required this.onCardTap,
    required this.onTimeTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // 获取当前的主题配置，实现日夜模式自动切换背景
    final theme = Theme.of(context);
    final cardBg = theme.cardColor; 
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    // --- 核心修改逻辑：判断是否显示“正计时” ---
    final isInfinite = currentMinutes == 0;
    final timeText = isInfinite ? "正计时" : "$currentMinutes 分钟";
    // 如果是中文“正计时”，我们可以不用 Courier 字体，而是用默认/宋体；数字则保持 Courier
    final timeFontFamily = isInfinite ? null : 'Courier'; 

    return GestureDetector(
      onTap: () {
        final shouldNavigate = onCardTap();
        if (shouldNavigate) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => FocusModeScreen(
                taskTitle: title,
                minutes: currentMinutes,
                taskColorValue: badgeColor.value,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      onLongPress: onLongPress, // 触发长按编辑
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: cardBg, // 动态背景色
          borderRadius: BorderRadius.circular(30),
          // 边框在深色模式下稍微明显一点，浅色模式下弱一点
          border: Border.all(
            color: theme.brightness == Brightness.dark 
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // 柔和阴影
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          children: [
            // 装饰性光晕
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor.withValues(alpha: 0.2), // 使用强调色
                ),
              ),
            ),
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // --- 时间区域 ---
                  GestureDetector(
                    onTap: onTimeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        // 适配日夜模式的微弱背景
                        color: theme.brightness == Brightness.dark 
                             ? Colors.white.withValues(alpha: 0.05)
                             : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeText, // 使用处理后的文本
                            style: TextStyle(
                              fontFamily: timeFontFamily, // 动态字体
                              color: textColor.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit, 
                            size: 14, 
                            color: textColor.withValues(alpha: 0.5)
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 标题
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300, // 细体
                      color: textColor,
                      letterSpacing: 2,
                      fontFamily: 'Noto Serif SC', // 确保标题始终宋体
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 2,
                    color: badgeColor, // 强调色横线
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
