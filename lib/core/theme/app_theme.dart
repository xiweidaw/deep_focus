import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- 基础调色板 ---
  static const Color _darkBackground = Color(0xFF000000); 
  static const Color _darkSurface = Color(0xFF141414);    
  static const Color _darkTextPrimary = Color(0xFFEAEAEA); 
  static const Color _darkTextSecondary = Color(0xFF888888); 

  static const Color _lightBackground = Color(0xFFF5F5F0); // 米白
  static const Color _lightSurface = Color(0xFFFFFFFF);    
  static const Color _lightTextPrimary = Color(0xFF2D2D2D); // 深墨色
  static const Color _lightTextSecondary = Color(0xFF6E6E6E); 

  // --- 兼容静态常量 ---
  static const Color background = _darkBackground;
  static const Color cardBackground = _darkSurface;
  static const Color textPrimary = _darkTextPrimary;
  static const Color textSecondary = _darkTextSecondary;
  
  // 🔥 新的强调色 #19c0f6 (你指定的青蓝色)
  static const Color accentColor = Color(0xFF19C0F6); 

  // 莫兰迪强调色 (调整了色板以适配青色)
  static const List<Color> taskColors = [
    Color(0xFF19C0F6), // 新主色
    Color(0xFF6B705C), // 橄榄绿
    Color(0xFFCB997E), // 铁锈红
    Color(0xFFA5A58D), // 枯草黄
    Color(0xFF8D99AE), // 雾蓝
    Color(0xFFB7B7A4), // 灰绿
  ];

  // --- 字体配置 ---
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.notoSerifScTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primary),
      displayMedium: base.displayMedium?.copyWith(color: primary),
      displaySmall: base.displaySmall?.copyWith(color: primary),
      headlineLarge: base.headlineLarge?.copyWith(color: primary),
      headlineMedium: base.headlineMedium?.copyWith(color: primary),
      headlineSmall: base.headlineSmall?.copyWith(color: primary),
      titleLarge: base.titleLarge?.copyWith(color: primary),
      titleMedium: base.titleMedium?.copyWith(color: primary),
      titleSmall: base.titleSmall?.copyWith(color: primary),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: primary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(color: primary),
      labelSmall: base.labelSmall?.copyWith(color: secondary),
    );
  }

  // --- ThemeData ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      primaryColor: accentColor,
      cardColor: _darkSurface,
      dividerColor: Colors.white, // 深色模式下的分割线
      colorScheme: const ColorScheme.dark(
        surface: _darkSurface,
        onSurface: _darkTextPrimary,
        secondary: _darkTextSecondary,
        primary: accentColor,
      ),
      textTheme: _buildTextTheme(_darkTextPrimary, _darkTextSecondary),
      useMaterial3: true,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      primaryColor: accentColor,
      cardColor: _lightSurface,
      dividerColor: Colors.black, // 浅色模式下的分割线
      colorScheme: const ColorScheme.light(
        surface: _lightSurface,
        onSurface: _lightTextPrimary,
        secondary: _lightTextSecondary,
        primary: accentColor,
      ),
      textTheme: _buildTextTheme(_lightTextPrimary, _lightTextSecondary),
      useMaterial3: true,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      iconTheme: const IconThemeData(color: _lightTextPrimary),
    );
  }
}
