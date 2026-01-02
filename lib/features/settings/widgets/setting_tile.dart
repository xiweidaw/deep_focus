import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showArrow;
  final Widget? trailing; // 新增：支持右侧放开关或其他组件

  const SettingTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // 获取当前主题文本颜色
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor, // 动态颜色
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (trailing != null) 
              trailing!
            else if (showArrow)
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
