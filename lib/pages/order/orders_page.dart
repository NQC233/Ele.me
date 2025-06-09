import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/order/order_list_tab.dart';

///
/// 订单页面 (已重构)
///
/// 使用TabBar和TabBarView来展示不同状态的订单列表。
///
class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 页面加载时，获取用户订单
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrders(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
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
            return const LoadingIndicator(text: '正在加载订单...');
          }

          final allOrders = orderProvider.orders;
          final processingOrders = orderProvider.getOrdersByStatus(OrderStatus.preparing)
            ..addAll(orderProvider.getOrdersByStatus(OrderStatus.delivering));
          final completedOrders = orderProvider.getOrdersByStatus(OrderStatus.completed);

          return TabBarView(
            controller: _tabController,
            children: [
              OrderListTab(orders: allOrders),
              OrderListTab(orders: processingOrders),
              OrderListTab(orders: completedOrders),
            ],
          );
        },
      ),
    );
  }
} 