import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import 'home_tab.dart';
import '../order/orders_page.dart';
import '../profile/profile_page.dart';

///
/// 应用主页框架 (已美化)
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

  // 页面控制器
  final PageController _pageController = PageController();

  // 页面列表
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeTab(),
    const OrdersPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // tab切换处理
  void _onItemTapped(int index) {
    if (index == 1) {
      // 订单页需要登录才能访问
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        // 如果未登录，则导航到登录页
        context.push(AppRoutes.login);
        return; // 阻止切换到订单页
      }
    }
    // 个人中心页不需要登录检查，已在页面内部处理
    
    setState(() {
      _selectedIndex = index;
      // 使用页面控制器平滑切换页面
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 禁用滑动切换
        children: _widgetOptions,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        elevation: 8,
        backgroundColor: theme.colorScheme.surface,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 500),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: theme.colorScheme.onPrimary,
            ),
            label: '首页',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(
              Icons.receipt_long,
              color: theme.colorScheme.onPrimary,
            ),
            label: '订单',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: theme.colorScheme.onPrimary,
            ),
            label: '我的',
          ),
        ],
      ),
    );
  }
} 