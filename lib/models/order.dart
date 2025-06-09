import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'cart.dart';
import 'user.dart';
import 'food.dart';
import '../config/app_theme.dart';
import 'address.dart';

// 订单状态枚举
enum OrderStatus {
  pending,   // 待支付
  preparing, // 商家制作中
  delivering, // 配送中
  completed, // 已完成
  cancelled, // 已取消
}

// OrderStatus的扩展，用于UI展示
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return '待支付';
      case OrderStatus.preparing:
        return '备货中';
      case OrderStatus.delivering:
        return '配送中';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.cancelled:
        return '已取消';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return AppTheme.primaryColor;
      case OrderStatus.delivering:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }
}

// 订单模型类
class Order {
  final String id;
  final String shopId;
  final String shopName;
  final String shopImage;
  final List<CartItem> items;
  final Address address;
  final double foodPrice; // 食品总价
  final double packingFee; // 包装费
  final double deliveryFee; // 配送费
  final double discount; // 优惠金额
  final double totalPrice; // 最终支付金额
  final OrderStatus status;
  final DateTime createTime;
  final DateTime? payTime;
  final DateTime? deliveryTime;
  final DateTime? completionTime;
  final String? cancelReason;
  final String? remark; // 订单备注
  final String? deliveryInfo; // 配送信息，如骑手姓名、电话等

  // 构造函数
  Order({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopImage,
    required this.items,
    required this.address,
    required this.foodPrice,
    required this.packingFee,
    required this.deliveryFee,
    required this.discount,
    required this.totalPrice,
    required this.status,
    required this.createTime,
    this.payTime,
    this.deliveryTime,
    this.completionTime,
    this.cancelReason,
    this.remark,
    this.deliveryInfo,
  });

  // 从JSON解析
  factory Order.fromJson(Map<String, dynamic> json) {
    List<CartItem> itemList = [];
    if (json['items'] != null) {
      itemList = List<CartItem>.from(
        json['items'].map((itemJson) {
          final food = Food.fromJson(itemJson['food']);
          return CartItem.fromJson(itemJson, food);
        }),
      );
    }

    return Order(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      shopName: json['shop_name'] as String,
      shopImage: json['shop_image'] as String,
      items: itemList,
      address: Address.fromJson(json['address']),
      foodPrice: (json['food_price'] as num).toDouble(),
      packingFee: (json['packing_fee'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: OrderStatus.values.byName(json['status'] as String),
      createTime: DateTime.parse(json['create_time'] as String),
      payTime: json['pay_time'] != null
          ? DateTime.parse(json['pay_time'] as String)
          : null,
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'] as String)
          : null,
      completionTime: json['completion_time'] != null
          ? DateTime.parse(json['completion_time'] as String)
          : null,
      cancelReason: json['cancel_reason'] as String?,
      remark: json['remark'] as String?,
      deliveryInfo: json['delivery_info'] as String?,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'shop_name': shopName,
      'shop_image': shopImage,
      'items': items.map((item) => item.toJson()).toList(),
      'address': address.toJson(),
      'food_price': foodPrice,
      'packing_fee': packingFee,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total_price': totalPrice,
      'status': status.name,
      'create_time': createTime.toIso8601String(),
      'pay_time': payTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'completion_time': completionTime?.toIso8601String(),
      'cancel_reason': cancelReason,
      'remark': remark,
      'delivery_info': deliveryInfo,
    };
  }

  // 创建副本并更新属性
  Order copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? shopImage,
    List<CartItem>? items,
    Address? address,
    double? foodPrice,
    double? packingFee,
    double? deliveryFee,
    double? discount,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createTime,
    DateTime? payTime,
    DateTime? deliveryTime,
    DateTime? completionTime,
    String? cancelReason,
    String? remark,
    String? deliveryInfo,
  }) {
    return Order(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopImage: shopImage ?? this.shopImage,
      items: items ?? this.items,
      address: address ?? this.address,
      foodPrice: foodPrice ?? this.foodPrice,
      packingFee: packingFee ?? this.packingFee,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      payTime: payTime ?? this.payTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      completionTime: completionTime ?? this.completionTime,
      cancelReason: cancelReason ?? this.cancelReason,
      remark: remark ?? this.remark,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
    );
  }

  // 计算订单中的商品总数量
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
} 