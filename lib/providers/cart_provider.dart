import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/food.dart';
import '../models/shop.dart';
import '../models/promotion.dart';
import '../services/index.dart';
import '../services/api_service.dart';
import '../services/shop_service.dart';
import '../services/order_service.dart';
import '../services/promotion_service.dart';

///
/// 购物车状态提供者
///
/// 负责管理应用的购物车状态。
///
/// 重构后的主要变更：
/// - 使用新的OrderService替换旧的ApiService
/// - 保留内存中购物车的管理逻辑，但增加了价格计算API集成
/// - 添加了价格计算功能，以便获取准确的优惠信息
///
class CartProvider extends ChangeNotifier {
  // 购物车实例
  Cart _cart = Cart(shopId: '', shopName: '', items: []);
  // 服务实例
  final OrderService _orderService = services.orderService;
  final PromotionService _promotionService = services.promotionService;
  final ShopService _shopService = ShopService(ApiService());
  
  // 价格计算结果
  Map<String, dynamic>? _priceCalculation;
  // 是否正在计算价格
  bool _isCalculatingPrice = false;
  
  // 获取购物车
  Cart get cart => _cart;

  // 获取购物车总金额
  double get totalPrice => _cart.totalPrice;

  // 获取购物车商品总数量
  int get totalItems => _cart.itemCount;
  
  // 获取价格计算结果
  Map<String, dynamic>? get priceCalculation => _priceCalculation;
  
  // 获取价格计算状态
  bool get isCalculatingPrice => _isCalculatingPrice;
  
  // 获取可用优惠总额
  double get discountAmount => _priceCalculation?['discountAmount']?.toDouble() ?? 0.0;
  
  // 获取配送费
  double get deliveryFee => _cart.deliveryFee;
  
  // 获取实际支付金额
  double get payAmount => _priceCalculation?['payAmount']?.toDouble() ?? _cart.finalPrice;

  // 获取指定食品在购物车中的数量
  int getQuantity(Food food) {
    final item = _cart.items.where((item) => item.food.id == food.id);
    return item.isEmpty ? 0 : item.first.quantity;
  }

  // 获取商店ID
  String get shopId => _cart.shopId;

  // 获取购物车是否为空
  bool get isEmpty => _cart.items.isEmpty;

  /// 清空购物车
  void clearCart() {
    _cart = Cart(shopId: '', shopName: '', items: []);
    _priceCalculation = null;
    notifyListeners();
  }

  /// 添加商品到购物车
  void addToCart(Food food, Shop shop) {
    if (_cart.shopId.isNotEmpty && _cart.shopId != shop.id) {
      clearCart();
    }

    final List<CartItem> updatedItems = List.from(_cart.items);
    final index = updatedItems.indexWhere((item) => item.food.id == food.id);

    if (index != -1) {
      final existingItem = updatedItems[index];
      updatedItems[index] = CartItem(food: existingItem.food, quantity: existingItem.quantity + 1);
    } else {
      updatedItems.add(CartItem(food: food, quantity: 1));
    }

    _cart = _cart.copyWith(
      shopId: shop.id,
      shopName: shop.name,
      shopImage: shop.logoUrl,
      items: updatedItems,
      deliveryFee: shop.deliveryFee,
    );

    notifyListeners();
  }

  /// 从购物车中减少一件商品
  void decreaseFromCart(Food food) {
    if (isEmpty) return;

    final List<CartItem> updatedItems = List.from(_cart.items);
    final index = updatedItems.indexWhere((item) => item.food.id == food.id);

    if (index != -1) {
      final existingItem = updatedItems[index];
      if (existingItem.quantity > 1) {
        updatedItems[index] = CartItem(food: existingItem.food, quantity: existingItem.quantity - 1);
      } else {
        updatedItems.removeAt(index);
      }
    }

    if (updatedItems.isEmpty) {
      clearCart();
    } else {
      _cart = _cart.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  /// 从购物车中移除一件商品
  void removeItem(Food food) {
    if (isEmpty) return;
    
    final List<CartItem> updatedItems = List.from(_cart.items)
      ..removeWhere((item) => item.food.id == food.id);

    if (updatedItems.isEmpty) {
      clearCart();
    } else {
      _cart = _cart.copyWith(items: updatedItems);
      notifyListeners();
    }
  }
  
  /// 计算订单价格（包括优惠信息）
  Future<void> calculateOrderPrice(String userId, String addressId, {String? couponId}) async {
    if (_cart.items.isEmpty) return;
    
    _isCalculatingPrice = true;
    notifyListeners();
    
    try {
      _priceCalculation = await _orderService.calculateOrderPrice(
        userId: userId,
        storeId: _cart.shopId,
        items: _cart.items.map((item) => {
          'productId': item.food.id,
          'productName': item.food.name,
          'price': item.food.price,
          'quantity': item.quantity,
        }).toList(),
        addressId: addressId,
        promotionId: couponId,
      );
    } catch (e) {
      debugPrint('计算订单价格失败: $e');
      _priceCalculation = null;
    } finally {
      _isCalculatingPrice = false;
      notifyListeners();
    }
  }
  
  /// 获取可用优惠列表
  Future<List<Promotion>> getOrderPromotions(String userId) async {
    if (_cart.items.isEmpty) return [];
    
    try {
      final items = _cart.items.map((item) => {
        'productId': item.food.id,
        'productName': item.food.name,
        'price': item.food.price,
        'quantity': item.quantity,
      }).toList();
      
      return await _promotionService.getOrderPromotions(
        userId: userId,
        storeId: _cart.shopId,
        totalAmount: totalPrice,
        items: items,
      );
    } catch (e) {
      debugPrint('获取可用优惠失败: $e');
      return [];
    }
  }

  void incrementItem(Food food) {
    if (isEmpty) return;

    final List<CartItem> updatedItems = List.from(_cart.items);
    final index = updatedItems.indexWhere((item) => item.food.id == food.id);

    if (index != -1) {
      final existingItem = updatedItems[index];
      updatedItems[index] = CartItem(food: existingItem.food, quantity: existingItem.quantity + 1);
      _cart = _cart.copyWith(items: updatedItems);
      notifyListeners();
    }
  }
} 