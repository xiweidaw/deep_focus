import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class RestScreen extends StatefulWidget {
  const RestScreen({super.key});

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _remainingSeconds = 5 * 60; // 固定 5 分钟
  
  // 呼吸动画
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. 简单的呼吸动画 (让休息更有生命感)
    _breathingController = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 2. 启动计时
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        _finishRest(); // 自然结束
      }
    });
  }

  void _finishRest() {
    HapticFeedback.heavyImpact(); // 震动提醒
    if (mounted) Navigator.pop(context); // 回到首页
  }

  @override
  void dispose() {
    _timer.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 休息模式专属色调：深青色/森林绿
    final bgColor = isDark ? const Color(0xFF1E2B25) : const Color(0xFFE8F5E9);
    final textColor = isDark ? const Color(0xFFC8E6C9) : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 呼吸圆
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathingAnimation.value,
                child: Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textColor.withValues(alpha: 0.05),
                  ),
                ),
              );
            },
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  "休 息 中",
                  style: TextStyle(
                    fontFamily: 'Noto Serif SC',
                    fontSize: 24,
                    color: textColor.withValues(alpha: 0.8),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _timerString,
                  style: TextStyle(
                    fontFamily: 'Noto Serif SC',
                    fontWeight: FontWeight.w100,
                    fontSize: 80,
                    color: textColor,
                    letterSpacing: -2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(flex: 3),
                
                // 跳过按钮
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "跳过休息",
                    style: TextStyle(color: textColor.withValues(alpha: 0.5), letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }
}
