import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/address.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../routes/app_routes.dart';
import '../../config/app_theme.dart';

///
/// 订单确认页面
///
/// 用户在此页面确认订单信息，包括地址、商品、费用和备注，并最终提交订单。
///
class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({Key? key}) : super(key: key);

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final _remarkController = TextEditingController();

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('确认订单'),
      ),
      body: Consumer2<CartProvider, UserProvider>(
        builder: (context, cartProvider, userProvider, child) {
          if (cartProvider.cart == null) {
            // 购物车为空，理论上不应到达此页
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
            return const Center(child: Text('购物车为空'));
          }

          final cart = cartProvider.cart!;
          final defaultAddress = userProvider.defaultAddress;

          if (defaultAddress == null) {
            return const Center(child: Text('请先设置一个默认地址'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildAddressSection(context, defaultAddress),
                    const SizedBox(height: 16),
                    _buildOrderItemsSection(context),
                    const SizedBox(height: 16),
                    _buildRemarkSection(context),
                  ],
                ),
              ),
              _buildSubmitBar(context),
            ],
          );
        },
      ),
    );
  }

  // 地址区域
  Widget _buildAddressSection(BuildContext context, Address address) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
        title: Text('${address.province} ${address.city} ${address.detail}'),
        subtitle: Text('${address.name} ${address.phone}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: 实现地址选择功能
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('地址选择功能待开发')));
        },
      ),
    );
  }

  // 商品清单区域
  Widget _buildOrderItemsSection(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false).cart!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cart.shopName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.food.name} x${item.quantity}'),
                  Text('¥${(item.food.price * item.quantity).toStringAsFixed(2)}'),
                ],
              ),
            )),
            const Divider(height: 24),
            _buildFeeRow('商品总额', '¥${cart.totalPrice.toStringAsFixed(2)}'),
            _buildFeeRow('配送费', '¥5.00'), // 示例费用
            _buildFeeRow('包装费', '¥2.00'), // 示例费用
          ],
        ),
      ),
    );
  }

  // 费用行
  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.secondaryTextColor)),
          Text(value),
        ],
      ),
    );
  }

  // 备注区域
  Widget _buildRemarkSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: _remarkController,
          decoration: const InputDecoration(
            hintText: '口味、偏好等要求',
            border: InputBorder.none,
          ),
          maxLines: 2,
        ),
      ),
    );
  }

  // 底部提交栏
  Widget _buildSubmitBar(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    const deliveryFee = 5.0;
    const packingFee = 2.0;
    final totalPrice = cartProvider.totalPrice + deliveryFee + packingFee;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: '合计: ', style: const TextStyle(fontSize: 16, color: AppTheme.textColor),
              children: <TextSpan>[
                TextSpan(text: '¥${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderProvider = Provider.of<OrderProvider>(context, listen: false);
              final userProvider = Provider.of<UserProvider>(context, listen: false);

              await orderProvider.createOrder(
                cart: cartProvider.cart!,
                address: userProvider.defaultAddress!,
                remark: _remarkController.text,
              );
              
              if(mounted) {
                // 清空购物车
                cartProvider.clearCart();
                // 提示成功并返回首页
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('订单提交成功!')));
                AppRoutes.router.go(AppRoutes.home);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('提交订单', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 