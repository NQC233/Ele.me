import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';

///
/// 商店页底部的购物车栏
///
class CartBar extends StatelessWidget {
  final Shop shop;
  const CartBar({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.isEmpty || cart.shopId != shop.id) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            AppRoutes.router.push(AppRoutes.cart);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.1).round()),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '¥${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '另需配送费 ¥${cart.deliveryFee.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    AppRoutes.router.push(AppRoutes.orderConfirmation);
                  },
                  child: Text('去结算 (${cart.totalItems})'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 