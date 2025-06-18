import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../models/order.dart' as model;
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';

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
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.currentOrder;

        if (orderProvider.isLoading && order == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('订单详情')),
            body: Center(child: Text(orderProvider.error ?? '无法加载订单详情')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(order.storeName)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusSection(context, order),
                const Divider(height: 32),
                _buildItemsSection(context, order),
                const Divider(height: 32),
                _buildPriceSection(context, order),
                const Divider(height: 32),
                _buildDeliverySection(context, order),
                const Divider(height: 32),
                _buildOrderInfoSection(context, order),
                const SizedBox(height: 20),
                _buildActionButtons(context, order),
              ],
            ),
          ),
        );
      },
    );
  }

  // 订单状态区块
  Widget _buildStatusSection(BuildContext context, model.Order order) {
    return Center(
      child: Column(
        children: [
          Text(order.status.displayName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: order.status.color)),
          const SizedBox(height: 8),
          Text('感谢您对${order.storeName}的信任，期待再次光临'),
        ],
      ),
    );
  }

  // 商品列表区块
  Widget _buildItemsSection(BuildContext context, model.Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(order.storeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...order.items.map((item) => ListTile(
              leading: Image.network(item.productImage, width: 40, height: 40, fit: BoxFit.cover),
              title: Text(item.productName),
              subtitle: Text('x${item.quantity}'),
              trailing: Text('¥${item.subtotal.toStringAsFixed(2)}'),
            )),
      ],
    );
  }
  
  // 价格信息区块
  Widget _buildPriceSection(BuildContext context, model.Order order) {
    return Column(
      children: [
        _buildPriceRow('商品总价', '¥${order.totalAmount.toStringAsFixed(2)}'),
        _buildPriceRow('配送费', '¥${order.deliveryFee.toStringAsFixed(2)}'),
        if (order.discountAmount > 0)
          _buildPriceRow('优惠金额', '-¥${order.discountAmount.toStringAsFixed(2)}', isHighlight: true),
        const Divider(),
        _buildPriceRow('实付金额', '¥${order.payAmount.toStringAsFixed(2)}', isHighlight: true),
      ],
    );
  }

  // 配送信息区块
  Widget _buildDeliverySection(BuildContext context, model.Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('配送信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildInfoRow('收货地址', order.receiverAddress),
        _buildInfoRow('收货人', order.receiverName),
        _buildInfoRow('联系电话', order.receiverPhone),
      ],
    );
  }

  // 订单信息区块
  Widget _buildOrderInfoSection(BuildContext context, model.Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('订单信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildInfoRow('订单号', order.orderNo),
        _buildInfoRow('下单时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createTime)),
        if (order.remark != null && order.remark!.isNotEmpty)
          _buildInfoRow('订单备注', order.remark!),
      ],
    );
  }
  
  // 操作按钮区块
  Widget _buildActionButtons(BuildContext context, model.Order order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    if (order.status == model.OrderStatus.pendingPayment) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton(
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
            child: const Text('取消订单'),
          ),
          ElevatedButton(
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
            child: const Text('立即支付'),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildPriceRow(String title, String amount, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 