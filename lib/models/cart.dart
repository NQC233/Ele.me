import 'food.dart';

// 购物车项模型类
class CartItem {
  final String id;
  final Food food;
  int quantity;
  final String? remark; // 备注

  // 构造函数
  CartItem({
    required this.id,
    required this.food,
    this.quantity = 1,
    this.remark,
  });

  // 从JSON解析
  factory CartItem.fromJson(Map<String, dynamic> json, Food food) {
    return CartItem(
      id: json['id'] as String,
      food: food,
      quantity: json['quantity'] as int,
      remark: json['remark'] as String?,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_id': food.id,
      'quantity': quantity,
      'remark': remark,
    };
  }

  // 创建副本并更新属性
  CartItem copyWith({
    String? id,
    Food? food,
    int? quantity,
    String? remark,
  }) {
    return CartItem(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      remark: remark ?? this.remark,
    );
  }

  // 计算总价
  double get totalPrice {
    return food.price * quantity;
  }

  // 获取规格选项描述
  String get optionsDescription {
    return '标准';
  }

  // 相同食品和选项的判断
  bool isSameConfig(CartItem other) {
    // 简化为只判断 food id 和 remark
    return food.id == other.food.id && remark == other.remark;
  }
}

// 购物车模型类
class Cart {
  final String shopId;
  final String shopName;
  final String shopImage;
  final List<CartItem> items;

  // 构造函数
  Cart({
    required this.shopId,
    required this.shopName,
    required this.shopImage,
    this.items = const [],
  });

  // 从JSON解析
  factory Cart.fromJson(Map<String, dynamic> json, Map<String, Food> foodMap) {
    List<CartItem> itemList = [];
    if (json['items'] != null) {
      json['items'].forEach((itemJson) {
        final foodId = itemJson['food_id'] as String;
        if (foodMap.containsKey(foodId)) {
          itemList.add(CartItem.fromJson(itemJson, foodMap[foodId]!));
        }
      });
    }

    return Cart(
      shopId: json['shop_id'] as String,
      shopName: json['shop_name'] as String,
      shopImage: json['shop_image'] as String,
      items: itemList,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'shop_name': shopName,
      'shop_image': shopImage,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // 创建副本并更新属性
  Cart copyWith({
    String? shopId,
    String? shopName,
    String? shopImage,
    List<CartItem>? items,
  }) {
    return Cart(
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopImage: shopImage ?? this.shopImage,
      items: items ?? this.items,
    );
  }

  // 计算购物车总价
  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // 计算购物车中的商品总数量
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // 清空购物车
  Cart clear() {
    return copyWith(items: []);
  }

  // 添加商品到购物车
  Cart addItem(CartItem newItem) {
    final newItems = List<CartItem>.from(items);
    
    // 寻找具有相同配置的商品
    final existingIndex = newItems.indexWhere((item) => item.isSameConfig(newItem));
    
    if (existingIndex >= 0) {
      // 如果找到相同配置的商品，增加数量
      final existing = newItems[existingIndex];
      newItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + newItem.quantity,
      );
    } else {
      // 否则添加新项目
      newItems.add(newItem);
    }
    
    return copyWith(items: newItems);
  }

  // 更新商品数量
  Cart updateItemQuantity(String itemId, int quantity) {
    final newItems = List<CartItem>.from(items);
    final index = newItems.indexWhere((item) => item.id == itemId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        // 如果数量为0或负数，移除商品
        newItems.removeAt(index);
      } else {
        // 否则更新数量
        final item = newItems[index];
        newItems[index] = item.copyWith(quantity: quantity);
      }
    }
    
    return copyWith(items: newItems);
  }

  // 移除商品
  Cart removeItem(String itemId) {
    final newItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: newItems);
  }
} 