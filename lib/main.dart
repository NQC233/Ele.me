import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'routes/app_routes.dart';
import 'config/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 MultiProvider 来包裹整个应用，以便全局提供状态管理服务
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp.router(
        title: '饿了么仿写', // 应用标题
        theme: AppTheme.getTheme(), // 修正: 使用 getTheme() 方法
        routerConfig: AppRoutes.router, // 路由配置
        debugShowCheckedModeBanner: false, // 隐藏调试横幅
      ),
    );
  }
}
