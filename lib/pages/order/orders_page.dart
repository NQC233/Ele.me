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
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
        bottom: TabBar(
          controller: _tabController,
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
            return const LoadingIndicator();
          }

          final allOrders = orderProvider.orders;
          
          // 筛选进行中的订单
          final processingOrders = allOrders.where((order) => 
            order.status == OrderStatus.pendingPayment ||
            order.status == OrderStatus.paid ||
            order.status == OrderStatus.preparing ||
            order.status == OrderStatus.delivering
          ).toList();
          
          // 筛选已完成的订单
          final completedOrders = allOrders.where((order) => 
            order.status == OrderStatus.completed
          ).toList();

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