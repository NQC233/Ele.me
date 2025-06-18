import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';

///
/// 订单列表选项卡
///
/// 一个可复用的Widget，用于在订单页的不同Tab中显示订单列表。
///
class OrderListTab extends StatelessWidget {
  /// 构造函数
  const OrderListTab({super.key, required this.status});

  /// 订单状态
  final String status;

  @override
  Widget build(BuildContext context) {
    // 获取订单数据
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final filteredOrders = status == 'all'
            ? orderProvider.orders
            : orderProvider.orders.where((order) {
                if (status == 'processing') {
                  return order.status == OrderStatus.pendingPayment ||
                      order.status == OrderStatus.paid ||
                      order.status == OrderStatus.preparing ||
                      order.status == OrderStatus.delivering;
                } else if (status == 'completed') {
                  return order.status == OrderStatus.completed;
                }
                return false;
              }).toList();

        if (orderProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (filteredOrders.isEmpty) {
          return EmptyPlaceholder(
            icon: Icons.receipt_long_outlined,
            title: '暂无${status == 'all' ? '' : _getStatusText(status)}订单',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(context, order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/order/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    order.status.displayName,
                    style: TextStyle(color: order.status.color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              if (order.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${order.items.first.productName} 等${order.totalQuantity}件商品',
                    style: const TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('总计 ¥${order.payAmount.toStringAsFixed(2)}'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'processing':
        return '进行中';
      case 'completed':
        return '已完成';
      default:
        return '';
    }
  }
} 