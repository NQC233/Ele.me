import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../providers/order_provider.dart';
import '../../models/order.dart' as model;
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

///
/// 订单详情页面
///
class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    // 使用 postFrameCallback 确保 BuildContext 已准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).getOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.currentOrder;

        if (orderProvider.isLoading && order == null) {
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('订单详情')),
            body: Center(child: Text(orderProvider.error ?? '无法加载订单详情')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('订单详情'),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.home),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusSection(context, order),
                const SizedBox(height: 16),
                _buildItemsSection(context, order),
                const SizedBox(height: 16),
                _buildPriceSection(context, order),
                const SizedBox(height: 16),
                _buildDeliverySection(context, order),
                const SizedBox(height: 16),
                _buildOrderInfoSection(context, order),
                const SizedBox(height: 24),
              ],
            ),
          ),
          bottomNavigationBar: _buildActionButtons(context, order),
        );
      },
    );
  }

  // 订单状态区块
  Widget _buildStatusSection(BuildContext context, model.Order order) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            order.status.color.withOpacity(0.8),
            order.status.color.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(order.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 商品列表区块
  Widget _buildItemsSection(BuildContext context, model.Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  order.storeName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.productImage,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (item.specification != null && item.specification!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.specification!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('x${item.quantity}'),
                      const SizedBox(height: 4),
                      Text(
                        '¥${item.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  // 价格信息区块
  Widget _buildPriceSection(BuildContext context, model.Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('费用明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPriceRow('商品总价', '¥${order.totalAmount.toStringAsFixed(2)}'),
            _buildPriceRow('配送费', '¥${order.deliveryFee.toStringAsFixed(2)}'),
            if (order.discountAmount > 0)
              _buildPriceRow('优惠金额', '-¥${order.discountAmount.toStringAsFixed(2)}', isHighlight: true),
            const Divider(height: 24),
            _buildPriceRow('实付金额', '¥${order.payAmount.toStringAsFixed(2)}', isHighlight: true, isBold: true),
          ],
        ),
      ),
    );
  }

  // 配送信息区块
  Widget _buildDeliverySection(BuildContext context, model.Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('配送信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, '收货人', order.receiverName),
            _buildInfoRow(Icons.phone, '联系电话', order.receiverPhone),
            _buildInfoRow(Icons.home, '收货地址', order.receiverAddress),
          ],
        ),
      ),
    );
  }

  // 订单信息区块
  Widget _buildOrderInfoSection(BuildContext context, model.Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('订单信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.numbers, '订单号', order.orderNo),
            _buildInfoRow(
              Icons.access_time, 
              '下单时间', 
              DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createTime),
            ),
            if (order.payTime != null)
              _buildInfoRow(
                Icons.payment, 
                '支付时间', 
                DateFormat('yyyy-MM-dd HH:mm:ss').format(order.payTime!),
              ),
            if (order.remark != null && order.remark!.isNotEmpty)
              _buildInfoRow(Icons.comment, '订单备注', order.remark!),
          ],
        ),
      ),
    );
  }
  
  // 操作按钮区块
  Widget? _buildActionButtons(BuildContext context, model.Order order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    if (order.status == model.OrderStatus.pendingPayment) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: orderProvider.isProcessing 
                  ? null 
                  : () async {
                      final success = await orderProvider.cancelOrder(order.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('订单已取消')),
                        );
                      }
                    },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: orderProvider.isProcessing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('取消订单'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: orderProvider.isProcessing 
                  ? null 
                  : () async {
                      final success = await orderProvider.payOrder(order.id, 'WECHAT');
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('支付成功')),
                        );
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: orderProvider.isProcessing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('立即支付'),
              ),
            ),
          ],
        ),
      );
    }
    
    return null;
  }

  Widget _buildPriceRow(String title, String amount, {bool isHighlight = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.redAccent : null,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(model.OrderStatus status) {
    switch (status) {
      case model.OrderStatus.pendingPayment:
        return Icons.payment;
      case model.OrderStatus.paid:
        return Icons.check_circle;
      case model.OrderStatus.preparing:
        return Icons.restaurant;
      case model.OrderStatus.delivering:
        return Icons.delivery_dining;
      case model.OrderStatus.completed:
        return Icons.task_alt;
      case model.OrderStatus.canceled:
        return Icons.cancel;
    }
  }
  
  String _getStatusDescription(model.OrderStatus status) {
    switch (status) {
      case model.OrderStatus.pendingPayment:
        return '请尽快完成支付';
      case model.OrderStatus.paid:
        return '商家已收到您的订单';
      case model.OrderStatus.preparing:
        return '商家正在准备您的美食';
      case model.OrderStatus.delivering:
        return '骑手正在配送中';
      case model.OrderStatus.completed:
        return '订单已完成，感谢您的信任';
      case model.OrderStatus.canceled:
        return '订单已取消';
    }
  }
} 