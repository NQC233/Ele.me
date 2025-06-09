import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../models/order.dart';
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
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    // 使用 postFrameCallback 确保 BuildContext 已准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .fetchOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentOrder == null) {
            return const LoadingIndicator();
          }

          if (provider.currentOrder == null) {
            return const Center(
              child: Text('订单不存在或加载失败'),
            );
          }

          final order = provider.currentOrder!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatusSection(order),
              const SizedBox(height: 20),
              _buildShopSection(context, order),
              const SizedBox(height: 20),
              _buildItemsSection(order),
              const SizedBox(height: 20),
              _buildPricingSection(order),
               const SizedBox(height: 20),
              _buildOrderInfoSection(order),
            ],
          );
        },
      ),
    );
  }

  // 订单状态区块
  Widget _buildStatusSection(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.status.displayName,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: order.status.color),
            ),
            const SizedBox(height: 8),
            const Text(
              '订单已送达，感谢您的信任，期待再次光临！', // 模拟文本
              style: TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
            ),
            const SizedBox(height: 16),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(onPressed: (){}, child: const Text("评价")),
                  ElevatedButton(onPressed: (){}, child: const Text("再来一单"))
                ],
              )
          ],
        ),
      ),
    );
  }

  // 店铺信息区块
  Widget _buildShopSection(BuildContext context, Order order) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(order.shopImage),
        ),
        title: Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: 跳转到店铺页面, 需要Shop对象
        },
      ),
    );
  }

  // 商品列表区块
  Widget _buildItemsSection(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.shopName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...order.items.map((item) => ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: item.food.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.food.name),
                  subtitle: Text('x ${item.quantity}'),
                  trailing: Text('¥${(item.food.price * item.quantity).toStringAsFixed(2)}'),
                )),
             const Divider(),
             ListTile(
              title: const Text("配送费"),
              trailing: Text('¥${order.deliveryFee.toStringAsFixed(2)}'),
            ),
             ListTile(
              title: const Text("包装费"),
              trailing: Text('¥${order.packingFee.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
  
  // 价格信息区块
  Widget _buildPricingSection(Order order) {
     return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             ListTile(
              title: const Text("优惠"),
              trailing: Text('- ¥${order.discount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
            ),
             ListTile(
              title: const Text("总计"),
              trailing: Text('¥${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // 订单信息区块
  Widget _buildOrderInfoSection(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('配送信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              title: const Text('收货地址'),
              subtitle: Text('${order.address.province}${order.address.city}${order.address.district}${order.address.detail}\n${order.address.name} ${order.address.phone}'),
            ),
             ListTile(
              title: const Text('配送方式'),
              subtitle: Text('商家配送'),
            ),
            const SizedBox(height: 16),
            const Text('订单信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
             ListTile(
              title: const Text('订单号'),
              subtitle: Text(order.id),
            ),
             ListTile(
              title: const Text('下单时间'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(order.createTime)),
            ),
             ListTile(
              title: const Text('支付方式'),
              subtitle: Text('在线支付'),
            ),
             if (order.remark != null && order.remark!.isNotEmpty)
              ListTile(
                title: const Text('备注信息'),
                subtitle: Text(order.remark!),
              ),
          ],
        ),
      ),
    );
  }
} 