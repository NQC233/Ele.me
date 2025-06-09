import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../../../providers/cart_provider.dart';
import '../../../routes/app_routes.dart';
import '../../config/app_theme.dart';

///
/// 商店页底部的购物车栏
///
class CartBar extends StatelessWidget {
  const CartBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        // 如果购物车为空，则不显示任何东西
        if (cart.cart == null || cart.itemCount == 0) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // 点击跳转到购物车页面
            AppRoutes.router.go(AppRoutes.cart);
          },
          child: Container(
            height: 60,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左侧购物车图标和总价
                Row(
                  children: [
                    badges.Badge(
                      badgeContent: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: AppTheme.secondaryColor,
                      ),
                      child: const Icon(Icons.shopping_cart, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '¥${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 右侧结算按钮
                const Text(
                  '去结算',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 