import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../timeline/models/focus_record.dart';

class FocusModeScreen extends StatefulWidget {
  final String taskTitle;
  final int minutes;
  final int taskColorValue;

  const FocusModeScreen({
    super.key,
    required this.taskTitle,
    required this.minutes,
    required this.taskColorValue,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> with TickerProviderStateMixin {
  late Timer _timer;
  late int _secondsCounter;
  late bool _isInfinite;
  
  // 核心状态
  bool _isPaused = false;
  bool _enableHaptics = true;

  // 动画控制器
  late AnimationController _exitAnimController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  
  // 提示文字动画控制器 (用于“双击暂停”的淡入淡出)
  late AnimationController _hintAnimController;
  late Animation<double> _hintOpacityAnimation;
  Timer? _hintHideTimer; // 用于延时隐藏提示

  late Map<String, String> _currentQuote;

  final List<Map<String, String>> _quotes = const [
    {'text': '知止而后有定，定而后能静。', 'source': '《大学》'},
    {'text': '非宁静无以致远。', 'source': '诸葛亮'},
    {'text': '慎终如始，则无败事。', 'source': '《道德经》'},
    {'text': '逝者如斯夫，不舍昼夜。', 'source': '《论语》'},
    {'text': '不积跬步，无以至千里。', 'source': '《荀子》'},
    {'text': '心无挂碍，无有恐怖。', 'source': '《心经》'},
    {'text': '行到水穷处，坐看云起时。', 'source': '王维'},
    {'text': '大音希声，大象无形。', 'source': '《道德经》'},
    {'text': '万物静观皆自得。', 'source': '程颢'},
  ];

  @override
  void initState() {
    super.initState();
    _isInfinite = widget.minutes == 0;
    _secondsCounter = _isInfinite ? 0 : widget.minutes * 60;
    
    final settings = StorageService.getBox<bool>('settings');
    _enableHaptics = settings.get('enableHaptics', defaultValue: true) ?? true;

    _currentQuote = _quotes[Random().nextInt(_quotes.length)];

    // 1. 退出动画
    _exitAnimController = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 1500)
    );
    _exitAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_enableHaptics) HapticFeedback.heavyImpact(); 
        _exitAnimController.reset();
        _showExitDialog();
      }
    });

    // 2. 呼吸动画
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    // 3. 提示文字动画 (300ms出现)
    _hintAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _hintOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintAnimController, curve: Curves.easeOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_isInfinite) {
          _secondsCounter++;
        } else {
          if (_secondsCounter > 0) {
            _secondsCounter--;
          } else {
            _timer.cancel();
            _handleFinish(isEarly: false);
          }
        }
      });
    });
  }

  // 单击触发：显示“双击暂停”提示，1.5秒后消失
  void _onSingleTap() {
    // 只有在运行状态下，单击才提示“双击暂停”。如果已经是暂停状态，界面已有显著变化，不需要提示。
    if (_isPaused) return;

    if (_enableHaptics) HapticFeedback.lightImpact();

    // 如果之前有定时器（正在倒计时隐藏），先取消
    _hintHideTimer?.cancel();

    // 显示提示
    _hintAnimController.forward();

    // 1.5秒后隐藏
    _hintHideTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _hintAnimController.reverse(); // 淡出
      }
    });
  }

  // 双击触发：真正暂停/继续
  void _onDoubleTap() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_enableHaptics) HapticFeedback.mediumImpact();

    // 无论如何，只要双击了，就隐藏“双击暂停”的提示文字（如果它还在显示）
    _hintAnimController.reverse(); 
    _hintHideTimer?.cancel();

    if (_isPaused) {
      _timer.cancel();
      _breathingController.stop();
    } else {
      _startTimer();
      _breathingController.repeat(reverse: true);
    }
  }

  Future<void> _handleFinish({required bool isEarly}) async {
    int durationMinutes;
    if (_isInfinite) {
      durationMinutes = (_secondsCounter / 60).ceil();
    } else {
      durationMinutes = isEarly 
          ? ((widget.minutes * 60 - _secondsCounter) / 60).ceil() 
          : widget.minutes;
    }
    
    if (durationMinutes > 0) {
      final record = FocusRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        taskTitle: widget.taskTitle,
        endTime: DateTime.now(),
        durationMinutes: durationMinutes,
        colorValue: widget.taskColorValue,
        note: _isInfinite ? "自由专注模式" : (isEarly ? "提前完成" : null), 
      );

      await StorageService.saveRecord(record);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("专注记录已保存"), duration: Duration(seconds: 2)),
      );
    }

    if (!mounted) return;
    Navigator.pop(context); 
  }

  void _showExitDialog() {
    if (!_isPaused) _onDoubleTap(); // 强制暂停

    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text("结束专注?", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: Text(_isInfinite 
              ? "是否结束当前的自由专注？"
              : "你要放弃这次专注，还是记录已完成的时间？",
              style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _onDoubleTap(); // 恢复
              },
              child: Text("继续", style: TextStyle(color: theme.disabledColor)),
            ),
            if (!_isInfinite) 
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("放弃", style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleFinish(isEarly: true);
              },
              child: Text(_isInfinite ? "完成" : "提前完成", 
                  style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _exitAnimController.dispose();
    _breathingController.dispose();
    _hintAnimController.dispose();
    _hintHideTimer?.cancel();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_secondsCounter / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsCounter % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    // 暂停时文字依然稍微变淡，或者你可以选择不变淡，全靠“已暂停”文字提示
    final textColor = theme.textTheme.bodyLarge?.color?.withValues(alpha: _isPaused ? 0.6 : 0.95);
    final accentColor = Color(widget.taskColorValue);

    return PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: bgColor,
        body: GestureDetector(
          // 🔥 核心交互升级
          onDoubleTap: _onDoubleTap, // 双击执行暂停
          onTap: _onSingleTap,       // 单击显示提示
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. 背景呼吸
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.15 : 0.05),
                            blurRadius: 100, spreadRadius: 20,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // 2. 中间：倒计时核心区域
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.taskTitle,
                            style: TextStyle(
                              fontFamily: 'Noto Serif SC', 
                              fontSize: 20,
                              fontWeight: FontWeight.w300, 
                              letterSpacing: 4,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // --- 提示文字层 (Tip / Paused Label) ---
                          // 这里我们用 Stack 来叠加“已暂停”和“双击暂停提示”，或者简单的条件判断
                          SizedBox(
                            height: 20, // 固定高度防止跳动
                            child: _isPaused 
                              ? Text(
                                  "已暂停", 
                                  style: TextStyle(fontSize: 12, color: theme.disabledColor, letterSpacing: 2)
                                )
                              : FadeTransition(
                                  opacity: _hintOpacityAnimation,
                                  child: Text(
                                    "双击暂停", 
                                    style: TextStyle(fontSize: 12, color: theme.disabledColor.withValues(alpha: 0.5), letterSpacing: 2, fontFamily: 'Noto Serif SC'),
                                  ),
                                ),
                          ),

                          Text(
                            _timerString,
                            style: TextStyle(
                              fontFamily: 'Noto Serif SC', 
                              fontSize: 100, 
                              fontWeight: FontWeight.w100,
                              color: textColor,
                              height: 1.0, 
                              letterSpacing: -4.0, 
                              fontFeatures: const [FontFeature.tabularFigures()], 
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 1),

                      // 3. 语录
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          children: [
                            Text(
                              "“${_currentQuote['text']}”",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Noto Serif SC',
                                fontSize: 18,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 1.2,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "— ${_currentQuote['source']}",
                              style: TextStyle(
                                fontFamily: 'Noto Serif SC',
                                fontSize: 12,
                                color: theme.disabledColor.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // 4. 底部长按
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              // 阻止长按的手势向上传递给父级(Single/Double Tap)
                              onTap: () {}, 
                              onLongPressStart: (_) {
                                if (_enableHaptics) HapticFeedback.mediumImpact(); 
                                _exitAnimController.forward();
                              },
                              onLongPressEnd: (_) {
                                if (_exitAnimController.status != AnimationStatus.completed) {
                                  _exitAnimController.reverse();
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 70, height: 70,
                                    child: AnimatedBuilder(
                                      animation: _exitAnimController,
                                      builder: (context, child) {
                                        return CircularProgressIndicator(
                                          value: _exitAnimController.value,
                                          strokeWidth: 1.5,
                                          backgroundColor: theme.disabledColor.withValues(alpha: 0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                          strokeCap: StrokeCap.round, 
                                        );
                                      },
                                    ),
                                  ),
                                  Icon(
                                    Icons.fingerprint, 
                                    size: 28, 
                                    color: theme.disabledColor.withValues(alpha: 0.3)
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "长按结束",
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.disabledColor.withValues(alpha: 0.3),
                                letterSpacing: 2
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
