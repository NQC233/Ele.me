import 'package:flutter/material.dart';

// 应用主题配置
class AppTheme {
  // 主要颜色 - 饿了么蓝色
  static const Color primaryColor = Color(0xFF0085FF);
  
  // 次要颜色 - 饿了么红色
  static const Color secondaryColor = Color(0xFFFF6000);
  
  // 背景颜色
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // 分割线颜色
  static const Color dividerColor = Color(0xFFEEEEEE);
  
  // 主文本颜色
  static const Color textColor = Color(0xFF333333);
  
  // 次要文本颜色
  static const Color secondaryTextColor = Color(0xFF666666);
  
  // 提示文本颜色
  static const Color hintTextColor = Color(0xFF999999);
  
  // 获取应用主题
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    // 其他通用主题设置
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // 其他深色主题设置
  );
} 