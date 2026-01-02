import 'package:flutter/material.dart';
import '../../core/storage/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    // 这里的泛型 <bool> 是为了防止 hive 报错，确保获取正确类型
    final box = StorageService.getBox<bool>('settings');
    final isDark = box.get('isDarkMode', defaultValue: true) ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    // 保存设置
    final box = StorageService.getBox<bool>('settings');
    box.put('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}
