import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../widgets/order/order_list_tab.dart';
import '../../config/app_theme.dart';

///
/// 订单页面 (已重构)
///
/// 使用TabBar和TabBarView来展示不同状态的订单列表。
///
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      Provider.of<OrderProvider>(context, listen: false).getUserOrders(userProvider.user!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '进行中'),
            Tab(text: '已完成'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          // 检查用户是否登录
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          if (!userProvider.isLoggedIn) {
            return const EmptyPlaceholder(
              icon: Icons.account_circle,
              title: '请先登录',
              subtitle: '登录后查看您的订单',
            );
          }
          
          // 检查是否有订单
          if (orderProvider.orders.isEmpty) {
            return const EmptyPlaceholder(
              icon: Icons.receipt_long,
              title: '暂无订单',
              subtitle: '去浏览更多美食吧',
            );
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              OrderListTab(status: 'all'),
              OrderListTab(status: 'processing'),
              OrderListTab(status: 'completed'),
            ],
          );
        },
      ),
    );
  }
} 