import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/cart.dart';
import '../models/food.dart';
import '../models/shop.dart';

///
/// 购物车状态提供者 (已重构)
///
/// 负责管理应用的购物车状态。
///
/// 重构后的主要变更：
/// - 移除了所有对`StorageService`的依赖，购物车状态只存在于内存中。
/// - 所有操作都修改为同步执行，简化了调用。
/// - 添加商品时，如果商品来自不同的商店，会自动清空旧的购物车。
///
class CartProvider extends ChangeNotifier {
  // 购物车实例
  Cart? _cart;
  // UUID生成器
  final Uuid _uuid = const Uuid();

  // 获取购物车
  Cart? get cart => _cart;

  // 获取购物车总金额
  double get totalPrice => _cart?.totalPrice ?? 0;

  // 获取购物车商品总数量
  int get itemCount => _cart?.totalQuantity ?? 0;

  // 获取指定食品在购物车中的数量
  int getQuantity(String foodId) {
    if (_cart == null) return 0;
    int quantity = 0;
    for (var item in _cart!.items) {
      if (item.food.id == foodId) {
        quantity += item.quantity;
      }
    }
    return quantity;
  }

  /// 清空购物车
  void clearCart() {
    _cart = null;
    notifyListeners();
  }

  /// 添加商品到购物车
  void addToCart(
    Shop shop,
    Food food, {
    int quantity = 1,
    String? remark,
  }) {
    // 如果购物车为空，或者切换了不同的商店，则创建新的购物车
    if (_cart == null || _cart!.shopId != shop.id) {
      _cart = Cart(
        shopId: shop.id,
        shopName: shop.name,
        shopImage: shop.image,
        items: [],
      );
    }
    
    // 查找购物车中是否已有该商品（忽略规格）
    final existingIndex = _cart!.items.indexWhere((item) => item.food.id == food.id);

    if (existingIndex >= 0) {
      // 如果存在，则数量+1
      final existingItem = _cart!.items[existingIndex];
      existingItem.quantity += quantity;
    } else {
      // 如果不存在，则创建新的购物车项
      final newItem = CartItem(
        id: _uuid.v4(), // CartItem的唯一ID
        food: food,
        quantity: quantity,
        remark: remark,
      );
      _cart!.items.add(newItem);
    }
    
    notifyListeners();
  }

  /// 从购物车中减少一件商品
  void decreaseFromCart(String foodId) {
    if (_cart == null) return;
    
    final existingIndex = _cart!.items.indexWhere((item) => item.food.id == foodId);
    
    if (existingIndex >= 0) {
      final existingItem = _cart!.items[existingIndex];
      existingItem.quantity--;
      
      if (existingItem.quantity <= 0) {
        _cart!.items.removeAt(existingIndex);
      }

      if (_cart!.items.isEmpty) {
        _cart = null;
      }
    }
    
    notifyListeners();
  }
} 