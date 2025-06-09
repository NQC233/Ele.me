import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/shop/shop_list_item.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../models/shop.dart';
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
  static const List<Widget> _pages = <Widget>[
    HomeTab(),
    OrdersPage(),
    ProfilePage(),
  ];

  // tab切换处理
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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