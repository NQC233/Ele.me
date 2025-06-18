import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

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
        final filteredOrders = _filterOrders(orderProvider.orders);

        if (orderProvider.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (filteredOrders.isEmpty) {
          return EmptyPlaceholder(
            icon: Icons.receipt_long_outlined,
            title: '暂无${status == 'all' ? '' : _getStatusText(status)}订单',
            subtitle: '去浏览更多美食吧',
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

  // 根据状态过滤订单
  List<Order> _filterOrders(List<Order> orders) {
    if (status == 'all') {
      return orders;
    } else if (status == 'processing') {
      return orders.where((order) =>
        order.status == OrderStatus.pendingPayment ||
        order.status == OrderStatus.paid ||
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.delivering
      ).toList();
    } else if (status == 'completed') {
      return orders.where((order) =>
        order.status == OrderStatus.completed
      ).toList();
    }
    return [];
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('${AppRoutes.orderDetail}/${order.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：店铺名称和订单状态
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        order.storeName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: TextStyle(
                        color: order.status.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 订单内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片
                  if (order.items.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: order.items.first.productImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.error, color: Colors.grey)),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  
                  // 订单信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.items.isNotEmpty)
                          Text(
                            order.items.first.productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '共${order.totalQuantity}件商品',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '下单时间：${DateFormat('yyyy-MM-dd HH:mm').format(order.createTime)}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 底部：价格和操作按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '实付金额：',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    '¥${order.payAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
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