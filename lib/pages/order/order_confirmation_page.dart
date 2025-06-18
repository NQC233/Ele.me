import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/address.dart';
import '../../models/promotion.dart';
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
  Promotion? _selectedPromotion;
  bool _loadingPromotions = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
    _loadAvailablePromotions();
  }

  // 加载默认地址
  Future<void> _loadDefaultAddress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      if (userProvider.addresses.isEmpty) {
        // 如果地址列表为空，尝试获取地址
        await userProvider.fetchAddresses();
      }
      
      setState(() {
        _selectedAddress = userProvider.defaultAddress;
      });
      
      if (_selectedAddress == null && userProvider.addresses.isNotEmpty) {
        // 如果没有默认地址但有地址，选择第一个
        setState(() {
          _selectedAddress = userProvider.addresses.first;
        });
      }
    }
  }

  // 加载可用优惠
  Future<void> _loadAvailablePromotions() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    if (!userProvider.isLoggedIn || cartProvider.isEmpty) return;
    
    setState(() {
      _loadingPromotions = true;
    });
    
    try {
      await orderProvider.getAvailablePromotions(
        userId: userProvider.user!.id,
        storeId: cartProvider.cart.shopId,
        totalAmount: cartProvider.totalPrice,
        items: cartProvider.cart.items.map((item) => {
          'productId': item.food.id,
          'productName': item.food.name,
          'price': item.food.price,
          'quantity': item.quantity,
        }).toList(),
      );
      
      // 获取用户优惠券，以便可以选择
      await orderProvider.getUserCoupons(userProvider.user!.id);
      
      // 如果有可用优惠，默认选择第一个
      if (orderProvider.availablePromotions.isNotEmpty) {
        setState(() {
          _selectedPromotion = orderProvider.availablePromotions.first;
        });
      }
    } catch (e) {
      debugPrint('加载优惠信息失败: $e');
    } finally {
      setState(() {
        _loadingPromotions = false;
      });
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
            _buildPromotionSection(context),
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
    if (userProvider.isLoading) {
      return const Center(child: LoadingIndicator(size: 24));
    }
    
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

    return Card(
      child: ListTile(
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
      ),
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
  
  Widget _buildPromotionSection(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final promotions = orderProvider.availablePromotions;
    
    if (_loadingPromotions) {
      return const Center(child: LoadingIndicator(size: 24));
    }
    
    if (promotions.isEmpty) {
      return const ListTile(
        title: Text('暂无可用优惠'),
        leading: Icon(Icons.local_offer_outlined),
      );
    }
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('可用优惠', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return RadioListTile<Promotion>(
                title: Text(promotion.title),
                subtitle: Text(promotion.description),
                secondary: Text('-¥${promotion.discountAmount.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                value: promotion,
                groupValue: _selectedPromotion,
                onChanged: (value) {
                  setState(() {
                    _selectedPromotion = value;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(BuildContext context, CartProvider cartProvider) {
    final double discountAmount = _selectedPromotion?.discountAmount ?? 0.0;
    final double totalPrice = cartProvider.totalPrice;
    final double deliveryFee = cartProvider.deliveryFee;
    final double finalAmount = totalPrice + deliveryFee - discountAmount;
    
    return Column(
      children: [
        _buildPriceRow('商品总价', '¥${totalPrice.toStringAsFixed(2)}'),
        _buildPriceRow('配送费', '¥${deliveryFee.toStringAsFixed(2)}'),
        if (_selectedPromotion != null)
          _buildPriceRow('优惠金额', '-¥${discountAmount.toStringAsFixed(2)}', isDiscount: true),
        const Divider(),
        _buildPriceRow('实付金额', '¥${finalAmount.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  Widget _buildPriceRow(String title, String amount, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            amount, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : null,
            ),
          ),
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
    final orderProvider = Provider.of<OrderProvider>(context);

    final double discountAmount = _selectedPromotion?.discountAmount ?? 0.0;
    final double totalAmount = cartProvider.totalPrice + cartProvider.deliveryFee - discountAmount;

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
                      promotionId: _selectedPromotion?.id,
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