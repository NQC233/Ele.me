import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import 'home_tab.dart';
import '../order/orders_page.dart';
import '../profile/profile_page.dart';


///
/// 应用主页框架 (已重构)
///
/// 这个Widget是应用的主屏幕，包含一个底部导航栏，用于在
/// "首页"、"订单" 和 "我的" 三个主要部分之间切换。
///
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 当前选中的tab索引
  int _selectedIndex = 0;

  // 页面列表
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeTab(),
    const OrdersPage(),
    const ProfilePage(),
  ];

  // tab切换处理
  void _onItemTapped(int index) {
    if (index == 1 || index == 2) {
      // 检查是否已登录
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        // 如果未登录，则导航到登录页
        context.push(AppRoutes.login);
        return; // 阻止切换到订单或个人中心页
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '订单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
} 