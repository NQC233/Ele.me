import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../common/empty_placeholder.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

///
/// 订单列表选项卡
///
/// 一个可复用的Widget，用于在订单页的不同Tab中显示订单列表。
///
class OrderListTab extends StatelessWidget {
  final List<Order> orders;

  const OrderListTab({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyPlaceholder(
        icon: Icons.receipt_long_outlined,
        title: '没有相关订单',
        subtitle: '去下一单，犒劳一下自己吧',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderItemCard(context, orders[index]);
      },
    );
  }

  // 构建单个订单卡片
  Widget _buildOrderItemCard(BuildContext context, Order order) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.orderDetails,
          pathParameters: {'orderId': order.id},
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCardHeader(context, order),
              const SizedBox(height: 16),
              _buildCardBody(context, order),
              const SizedBox(height: 16),
              _buildCardFooter(context, order),
            ],
          ),
        ),
      ),
    );
  }

  // 订单卡片头部
  Widget _buildCardHeader(BuildContext context, Order order) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(order.shopImage),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Text(
          order.status.displayName,
          style: TextStyle(color: order.status.color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // 订单卡片主体（商品信息）
  Widget _buildCardBody(BuildContext context, Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 商品图片缩略图
        Expanded(
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: order.items[index].food.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 价格和数量
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('¥${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('共${order.totalQuantity}件', style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
          ],
        )
      ],
    );
  }

  // 订单卡片底部（操作按钮）
  Widget _buildCardFooter(BuildContext context, Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () { /* TODO: 再来一单 */ },
          child: const Text('再来一单'),
        ),
        if (order.status == OrderStatus.completed) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () { /* TODO: 评价 */ },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('评价', style: TextStyle(color: Colors.white)),
          ),
        ],
      ],
    );
  }
} 