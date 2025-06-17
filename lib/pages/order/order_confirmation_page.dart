import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/address.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../routes/app_routes.dart';

///
/// 订单确认页面 (已重构)
///
/// 用户在此页面确认订单信息，包括地址、商品、费用和备注，并最终提交订单。
/// 重构后使用真实API计算价格，显示优惠信息。
///
class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({super.key});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  Address? _selectedAddress;
  String? _remark;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      _selectedAddress = userProvider.defaultAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (cartProvider.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("购物车是空的，无法下单")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('确认订单')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(context, userProvider),
            const Divider(height: 32),
            _buildOrderItems(context, cartProvider),
            const Divider(height: 32),
            _buildPriceDetails(context, cartProvider),
            const Divider(height: 32),
            _buildRemarkSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAddressSection(BuildContext context, UserProvider userProvider) {
    if (_selectedAddress == null) {
      return ListTile(
        title: const Text('请选择收货地址'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await context.push<Address>(AppRoutes.addressList);
          if (result != null) {
            setState(() {
              _selectedAddress = result;
            });
          }
        },
      );
    }

    return ListTile(
      title: Text('${_selectedAddress!.receiverName} ${_selectedAddress!.receiverPhone}'),
      subtitle: Text(_selectedAddress!.fullAddress),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await context.push<Address>(AppRoutes.addressList);
        if (result != null) {
          setState(() {
            _selectedAddress = result;
          });
        }
      },
    );
  }

  Widget _buildOrderItems(BuildContext context, CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cartProvider.cart.shopName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...cartProvider.cart.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Image.network(item.food.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                const SizedBox(width: 16),
                Expanded(child: Text(item.food.name)),
                Text('x${item.quantity}'),
                const SizedBox(width: 16),
                Text('¥${(item.food.price * item.quantity).toStringAsFixed(2)}'),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPriceDetails(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        _buildPriceRow('商品总价', '¥${cartProvider.totalPrice.toStringAsFixed(2)}'),
        _buildPriceRow('配送费', '¥${cartProvider.deliveryFee.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildPriceRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(amount),
        ],
      ),
    );
  }

  Widget _buildRemarkSection() {
    return TextField(
      decoration: const InputDecoration(
        hintText: '给商家留言...',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _remark = value;
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final totalAmount = cartProvider.totalPrice + cartProvider.deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('总计: ¥${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: (userProvider.isLoading || _selectedAddress == null)
                ? null
                : () async {
                    final order = await orderProvider.createOrder(
                      userId: userProvider.user!.id,
                      cart: cartProvider.cart,
                      address: _selectedAddress!,
                      remark: _remark,
                    );
                    if (order != null && mounted) {
                      cartProvider.clearCart();
                      context.go('${AppRoutes.orderDetail}/${order.id}');
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('下单失败: ${orderProvider.error ?? '未知错误'}')),
                      );
                    }
                  },
            child: orderProvider.isLoading ? const LoadingIndicator(size: 20) : const Text('提交订单'),
          ),
        ],
      ),
    );
  }
} 