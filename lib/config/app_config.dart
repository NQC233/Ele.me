import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 应用配置类
class AppConfig {
  // 设计稿尺寸
  static const double designWidth = 375;
  static const double designHeight = 812;
  
  // 是否是生产环境
  static const bool isProduction = false;
  
  // API基础URL
  static const String apiBaseUrl = isProduction
      ? 'https://api.example.com/v1'  // 生产环境
      : 'https://dev-api.example.com/v1';  // 开发环境
  
  // 应用名称
  static const String appName = '饿了么';
  
  // 应用版本
  static const String appVersion = '1.0.0';
  
  // 应用描述
  static const String appDescription = '饿了么 - 外卖订餐平台';
  
  // 初始化屏幕适配工具
  static void initScreenUtil(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(designWidth, designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }
  
  // 根据设计稿尺寸适配宽度
  static double setWidth(double width) {
    return width.w;
  }
  
  // 根据设计稿尺寸适配高度
  static double setHeight(double height) {
    return height.h;
  }
  
  // 根据设计稿尺寸适配字体大小
  static double setSp(double fontSize) {
    return fontSize.sp;
  }
  
  // 根据设计稿尺寸适配半径
  static double setRadius(double radius) {
    return radius.r;
  }
  
  // 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;
  
  // 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;
  
  // 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
} 