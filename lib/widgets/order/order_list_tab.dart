import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/order.dart' as model;
import '../common/empty_placeholder.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

///
/// 订单列表选项卡
///
/// 一个可复用的Widget，用于在订单页的不同Tab中显示订单列表。
///
class OrderListTab extends StatelessWidget {
  final List<model.Order> orders;

  const OrderListTab({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyPlaceholder(
        icon: Icons.receipt_long_outlined,
        title: '没有相关订单',
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
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
      },
    );
  }
} 