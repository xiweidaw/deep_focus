import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/storage/storage_service.dart';
import '../../timeline/models/focus_record.dart';
import '../widgets/stats_overview.dart';
import '../widgets/setting_tile.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  // 震动开关状态
  late bool _enableHaptics;

  @override
  void initState() {
    super.initState();
    // 从 Hive 读取设置，默认为 true
    final settings = StorageService.getBox<bool>('settings');
    _enableHaptics = settings.get('enableHaptics', defaultValue: true) ?? true;
  }

  void _toggleHaptics(bool value) {
    setState(() => _enableHaptics = value);
    StorageService.getBox<bool>('settings').put('enableHaptics', value);
    if(value) HapticFeedback.mediumImpact();
  }

  // --- 头衔计算逻辑 ---
  String _getLevelTitle(int totalHours) {
    if (totalHours < 10) return "入 门";
    if (totalHours < 50) return "修 行";
    if (totalHours < 200) return "洞 见";
    return "觉 者";
  }

  String _getLevelSubtitle(int totalHours) {
    if (totalHours < 10) return "万事开头难，静心起步";
    if (totalHours < 50) return "日积跬步，渐入佳境";
    if (totalHours < 200) return "心无旁骛，见微知著";
    return "大音希声，大象无形";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ValueListenableBuilder<Box<FocusRecord>>(
        valueListenable: StorageService.listenToRecords(),
        builder: (context, box, _) {
          // 重新计算总时长以获取等级
          final records = box.values.toList();
          final totalMinutes = records.fold<int>(0, (sum, item) => sum + item.durationMinutes);
          final totalHours = (totalMinutes / 60).floor();

          final levelTitle = _getLevelTitle(totalHours);
          final levelDesc = _getLevelSubtitle(totalHours);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    
                    // --- 1. 头衔与头像 (Gamification) ---
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.cardColor,
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                              ]
                            ),
                            child: Center(
                              child: Icon(Icons.person, size: 40, color: theme.disabledColor),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 等级大标题 (宋体)
                          Text(
                            levelTitle,
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: 'Noto Serif SC', // 宋体
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 等级描述
                          Text(
                            levelDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: subTextColor,
                              fontFamily: 'Noto Serif SC',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // --- 2. 仪表盘 (Reuse) ---
                    const Text(
                      "数据概览",
                      style: TextStyle(color: AppTheme.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const StatsOverview(),

                    const SizedBox(height: 50),

                    // --- 3. 设置列表 ---
                    const Text(
                      "通用设置",
                      style: TextStyle(color: AppTheme.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // 日夜模式
                    SettingTile(
                      title: "夜间模式",
                      icon: Icons.dark_mode_outlined,
                      onTap: () => themeProvider.toggleTheme(),
                      trailing: Switch.adaptive(
                        value: themeProvider.isDarkMode,
                        activeColor: AppTheme.accentColor,
                        onChanged: (val) => themeProvider.toggleTheme(),
                      ),
                    ),
                    _buildDivider(theme),

                    // 震动反馈
                    SettingTile(
                      title: "震动反馈",
                      icon: Icons.vibration,
                      onTap: () => _toggleHaptics(!_enableHaptics),
                      trailing: Switch.adaptive(
                        value: _enableHaptics,
                        activeColor: AppTheme.accentColor,
                        onChanged: _toggleHaptics,
                      ),
                    ),
                    _buildDivider(theme),

                    // 隐私说明
                    SettingTile(
                      title: "隐私说明",
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: theme.cardColor,
                            title: const Text("隐私承诺"),
                            content: const Text(
                              "DeepFocus 是一款离线优先的应用。\n\n您的所有专注数据、日记内容均仅存储在您手机的本地数据库中，我们无法、也不会上传到任何云端服务器。\n\n请放心记录。",
                              style: TextStyle(height: 1.5),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("了解", style: TextStyle(color: AppTheme.accentColor)),
                              )
                            ],
                          )
                        );
                      },
                    ),
                    _buildDivider(theme),

                    // 意见反馈
                    SettingTile(
                      title: "意见反馈",
                      icon: Icons.mail_outline,
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: "J3319874932@163.com"));
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("邮箱已复制到了剪贴板"), duration: Duration(seconds: 2))
                        );
                      },
                    ),
                    _buildDivider(theme),

                    // 关于
                    SettingTile(
                      title: "关于",
                      icon: Icons.info_outline,
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "DeepFocus",
                          applicationVersion: "v1.0.0",
                          applicationIcon: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.lens, color: Colors.white),
                          ),
                          children: [
                            const SizedBox(height: 20),
                            const Text("极简 · 专注 · 复盘"),
                            const SizedBox(height: 10),
                            const Text("Designed for minimalist minds.", style: TextStyle(fontFamily: 'Courier', fontSize: 12)),
                          ] 
                        );
                      },
                    ),
                    
                    const SizedBox(height: 60),
                    Center(
                      child: Text(
                        "DeepFocus v1.0.0", 
                        style: TextStyle(fontFamily: 'Courier', color: subTextColor?.withValues(alpha: 0.3), fontSize: 10)
                      )
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 56);
  }
}
