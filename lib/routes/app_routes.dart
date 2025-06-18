import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/address.dart';
import '../models/shop.dart';

import '../pages/home/home_page.dart';
import '../pages/shop/shop_page.dart';
import '../pages/cart/cart_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/search/search_page.dart';
import '../pages/order/order_confirmation_page.dart';
import '../pages/profile/address_list_page.dart';
import '../pages/profile/address_edit_page.dart';
import '../pages/order/order_details_page.dart';
import '../pages/order/orders_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/profile/coupons_page.dart';

///
/// 应用路由配置
///
/// 使用 GoRouter 进行统一的路由管理。
///
class AppRoutes {
  // 定义路由名称常量，便于引用和维护
  static const String home = '/';
  static const String shop = '/shop';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/detail';
  static const String login = '/login';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String addressList = '/profile/address';
  static const String addressEdit = '/profile/address/edit';
  static const String addressAdd = '/profile/address/add';
  static const String orderConfirmation = '/order/confirm';
  static const String coupons = '/profile/coupons';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true, // 开发时开启日志，方便调试
    routes: [
      GoRoute(
        path: home,
        name: home,
        builder: (context, state) => const HomePage(),
      ),
      // 使用路径参数方式配置shop路由
      GoRoute(
        path: '$shop/:shopId',
        name: 'shop_details',
        builder: (context, state) {
          final shopId = state.pathParameters['shopId']!;
          debugPrint('打开商店详情，ID: $shopId');
          return ShopPage(shopId: shopId);
        },
      ),
      // 保留旧的shop路由，兼容性处理
      GoRoute(
        path: shop,
        name: shop,
        builder: (context, state) {
          // 支持两种方式传递店铺ID：
          // 1. 作为extra参数传递Shop对象
          // 2. 作为extra参数直接传递shopId字符串
          if (state.extra != null) {
            if (state.extra is Shop) {
              final shop = state.extra as Shop;
              return ShopPage(shopId: shop.id);
            } else if (state.extra is String) {
              final shopId = state.extra as String;
              return ShopPage(shopId: shopId);
            }
          }
          // 默认情况或无效参数，返回首页
          return const HomePage();
        },
      ),
      GoRoute(
        path: cart,
        name: cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: orders,
        name: orders,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: orderDetail,
        name: orderDetail,
        builder: (context, state) {
          final orderId = state.extra as String;
          return OrderDetailsPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: login,
        name: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: search,
        name: search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: profile,
        name: profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: addressList,
        name: addressList,
        builder: (context, state) => const AddressListPage(),
      ),
      GoRoute(
        path: addressEdit,
        name: addressEdit,
        builder: (context, state) {
          final address = state.extra as Address;
          return AddressEditPage(initialAddress: address);
        },
      ),
      GoRoute(
        path: addressAdd,
        name: addressAdd,
        builder: (context, state) => const AddressEditPage(),
      ),
      GoRoute(
        path: orderConfirmation,
        name: orderConfirmation,
        builder: (context, state) => const OrderConfirmationPage(),
      ),
      GoRoute(
        path: coupons,
        name: coupons,
        builder: (context, state) => const CouponsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Text('错误: ${state.error}'),
      ),
    ),
  );
} 