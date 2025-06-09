import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/address.dart';
import '../models/shop.dart';
import '../models/user.dart';

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
  static const String profile = '/profile';
  static const String search = '/search';
  static const String login = '/login';
  static const String orderConfirmation = '/order-confirmation';
  static const String addressList = '/profile/address';
  static const String addressAdd = '/address-add';
  static const String addressEdit = '/profile/address/edit';
  static const String orderDetails = '/order/:orderId';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true, // 开发时开启日志，方便调试
    routes: [
      GoRoute(
        path: home,
        name: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: shop,
        name: shop,
        builder: (context, state) {
          final shop = state.extra as Shop;
          return ShopPage(shopId: shop.id);
        },
      ),
      GoRoute(
        path: cart,
        name: cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: orders,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: search,
        name: search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: login,
        name: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: orderConfirmation,
        name: orderConfirmation,
        builder: (context, state) => const OrderConfirmationPage(),
      ),
      GoRoute(
        path: addressList,
        name: addressList,
        builder: (context, state) => const AddressListPage(),
      ),
      GoRoute(
        path: addressAdd,
        builder: (context, state) => const AddressEditPage(),
      ),
      GoRoute(
        path: addressEdit,
        name: addressEdit,
        builder: (context, state) => AddressEditPage(initialAddress: state.extra as Address?),
      ),
      GoRoute(
        path: orderDetails,
        name: orderDetails,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailsPage(orderId: orderId);
        },
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