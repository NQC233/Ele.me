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
    final theme = Theme.of(context);

    if (cartProvider.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('确认订单')),
        body: const Center(child: Text("购物车是空的，无法下单")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('确认订单'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(context, userProvider),
            const SizedBox(height: 12),
            _buildOrderItems(context, cartProvider),
            const SizedBox(height: 12),
            _buildPromotionSection(context),
            const SizedBox(height: 12),
            _buildPriceDetails(context, cartProvider),
            const SizedBox(height: 12),
            _buildRemarkSection(),
            const SizedBox(height: 100), // 为底部按钮留出空间
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAddressSection(BuildContext context, UserProvider userProvider) {
    final theme = Theme.of(context);
    
    if (userProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: LoadingIndicator(size: 24)),
      );
    }
    
    if (_selectedAddress == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.add_location_alt, color: theme.colorScheme.primary),
          title: const Text('请选择收货地址', style: TextStyle(fontWeight: FontWeight.bold)),
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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(Icons.location_on, color: theme.colorScheme.primary),
        title: Row(
          children: [
            Text(
              _selectedAddress!.receiverName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(_selectedAddress!.receiverPhone),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(_selectedAddress!.fullAddress),
        ),
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
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.store, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  cartProvider.cart.shopName, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cartProvider.cart.items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = cartProvider.cart.items[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.food.imageUrl, 
                        width: 60, 
                        height: 60, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.food.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¥${item.food.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                          '¥${(item.food.price * item.quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPromotionSection(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final promotions = orderProvider.availablePromotions;
    final theme = Theme.of(context);
    
    if (_loadingPromotions) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: LoadingIndicator(size: 24)),
      );
    }
    
    if (promotions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(Icons.local_offer_outlined, color: theme.colorScheme.primary),
          title: const Text('暂无可用优惠'),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.local_offer, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('可用优惠', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: promotions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return RadioListTile<Promotion>(
                title: Text(
                  promotion.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  promotion.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                secondary: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '-¥${promotion.discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                value: promotion,
                groupValue: _selectedPromotion,
                activeColor: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final double discountAmount = _selectedPromotion?.discountAmount ?? 0.0;
    final double totalPrice = cartProvider.totalPrice;
    final double deliveryFee = cartProvider.deliveryFee;
    final double finalAmount = totalPrice + deliveryFee - discountAmount;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('费用明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPriceRow('商品总价', '¥${totalPrice.toStringAsFixed(2)}'),
          _buildPriceRow('配送费', '¥${deliveryFee.toStringAsFixed(2)}'),
          if (_selectedPromotion != null)
            _buildPriceRow('优惠金额', '-¥${discountAmount.toStringAsFixed(2)}', isDiscount: true),
          const Divider(height: 24),
          _buildPriceRow('实付金额', '¥${finalAmount.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String amount, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            amount, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : (isBold ? Theme.of(context).colorScheme.primary : null),
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkSection() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('订单备注', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: '给商家留言...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            maxLines: 3,
            onChanged: (value) {
              _remark = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final theme = Theme.of(context);

    final double discountAmount = _selectedPromotion?.discountAmount ?? 0.0;
    final double totalAmount = cartProvider.totalPrice + cartProvider.deliveryFee - discountAmount;

    return Container(
      padding: const EdgeInsets.all(16.0),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('实付金额', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '¥${totalAmount.toStringAsFixed(2)}', 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: (userProvider.isLoading || _selectedAddress == null || orderProvider.isLoading)
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
                        context.go(AppRoutes.payment, extra: order.id);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('下单失败: ${orderProvider.error ?? '未知错误'}')),
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
              child: orderProvider.isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('提交订单', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
} 