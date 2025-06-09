import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../models/cart.dart';
import '../../models/shop.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

///
/// 购物车页面 (已重构)
///
/// 展示购物车中的商品列表，并提供结算功能。
///
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
        actions: [
          TextButton(
            onPressed: () {
              // 添加清空购物车逻辑
              Provider.of<CartProvider>(context, listen: false).clearCart();
            },
            child: const Text('清空', style: TextStyle(color: AppTheme.textColor)),
          )
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cart == null || cartProvider.itemCount == 0) {
            return const EmptyPlaceholder(
              icon: Icons.shopping_cart_outlined,
              title: '购物车是空的',
              subtitle: '快去挑选一些喜欢的商品吧',
            );
          }
          return _buildCartContent(context, cartProvider);
        },
      ),
    );
  }

  // 构建购物车主体内容
  Widget _buildCartContent(BuildContext context, CartProvider cartProvider) {
    final cart = cartProvider.cart!;
    return Column(
      children: [
        // 商品列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(context, cart, item, cartProvider);
            },
          ),
        ),
        // 底部结算栏
        _buildBottomBar(context, cart),
      ],
    );
  }

  // 构建单个购物车商品项
  Widget _buildCartItem(BuildContext context, Cart cart, CartItem item, CartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.food.image, width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.food.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('¥${item.food.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor)),
                ],
              ),
            ),
            // 数量控制器
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                  onPressed: () => cartProvider.decreaseFromCart(item.food.id),
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                  onPressed: () {
                    // 构造临时的Shop对象以匹配addToCart的签名
                    final tempShop = Shop(
                      id: cart.shopId,
                      name: cart.shopName,
                      image: cart.shopImage,
                      // 其他字段为必需，但在此上下文中不重要，使用默认值
                      rating: 0,
                      monthSales: 0,
                      deliveryTime: 0,
                      deliveryFee: 0,
                      minOrderAmount: 0,
                      distance: 0,
                      address: '',
                      businessHours: [],
                      notice: '',
                    );
                    cartProvider.addToCart(tempShop, item.food);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 构建底部结算栏
  Widget _buildBottomBar(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 总计金额
          RichText(
            text: TextSpan(
              text: '合计: ',
              style: const TextStyle(fontSize: 16, color: AppTheme.textColor),
              children: <TextSpan>[
                TextSpan(
                  text: '¥${cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          // 结算按钮
          ElevatedButton(
            onPressed: () {
              AppRoutes.router.push(AppRoutes.orderConfirmation);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('去结算', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 