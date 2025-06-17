import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../routes/app_routes.dart';

///
/// 购物车页面 (已重构)
///
/// 展示购物车中的商品列表，并提供结算功能。
///
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    if (cartProvider.isEmpty) {
      return const EmptyPlaceholder(
        icon: Icons.shopping_cart_outlined,
        title: '购物车是空的',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('购物车 (${cartProvider.shopId})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => cartProvider.clearCart(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cartProvider.cart.items.length,
        itemBuilder: (context, index) {
          final item = cartProvider.cart.items[index];
          return ListTile(
            leading: Image.network(item.food.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(item.food.name),
            subtitle: Text('¥${item.food.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => cartProvider.decreaseFromCart(item.food),
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => cartProvider.incrementItem(item.food),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '总计: ¥${cartProvider.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              if (userProvider.isLoggedIn) {
                AppRoutes.router.push(AppRoutes.orderConfirmation);
              } else {
                AppRoutes.router.push(AppRoutes.login);
              }
            },
            child: const Text('去结算'),
          ),
        ],
      ),
    );
  }
} 