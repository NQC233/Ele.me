import 'food.dart';

/// 购物车模型
class Cart {
  final String shopId;
  final String shopName;
  final String? shopImage;
  final List<CartItem> items;
  final double deliveryFee;

  Cart({
    required this.shopId,
    required this.shopName,
    this.shopImage,
    this.items = const [],
    this.deliveryFee = 0.0,
  });

  // 计算商品总数
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // 计算商品总价
  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  // 计算包含配送费的总金额
  double get finalPrice => totalPrice + deliveryFee;

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemList = <CartItem>[];
    if (json['items'] != null) {
      itemList = (json['items'] as List)
          .map((itemJson) => CartItem.fromJson(itemJson))
          .toList();
    }
    return Cart(
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      shopImage: json['shopImage'] as String?,
      items: itemList,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'shopImage': shopImage,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryFee': deliveryFee,
    };
  }

   Cart copyWith({
    String? shopId,
    String? shopName,
    String? shopImage,
    List<CartItem>? items,
    double? deliveryFee,
  }) {
    return Cart(
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopImage: shopImage ?? this.shopImage,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}

/// 购物车商品项
class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  // 小计
  double get totalPrice => food.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      food: Food.fromJson(json['food']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food.toJson(),
      'quantity': quantity,
    };
  }
} 