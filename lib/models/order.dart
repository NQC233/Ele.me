import 'package:flutter/material.dart';
import '../config/app_theme.dart';

// 订单状态枚举
enum OrderStatus {
  pendingPayment,
  paid,
  preparing,
  delivering,
  completed,
  canceled,
}

// OrderStatus的扩展，用于UI展示
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pendingPayment:
        return '待支付';
      case OrderStatus.paid:
        return '已支付';
      case OrderStatus.preparing:
        return '备货中';
      case OrderStatus.delivering:
        return '配送中';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.canceled:
        return '已取消';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pendingPayment:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.blue;
      case OrderStatus.preparing:
        return AppTheme.primaryColor;
      case OrderStatus.delivering:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.grey;
    }
  }
}

// 订单模型
class Order {
  final String id;
  final String orderNo;
  final String userId;
  final String storeId;
  final String storeName;
  final String storeImage;
  final OrderStatus status;
  final String statusDesc;
  final double totalAmount;
  final double payAmount;
  final double discountAmount;
  final double deliveryFee;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final String? remark;
  final DateTime createTime;
  final DateTime? payTime;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.storeImage,
    required this.status,
    required this.statusDesc,
    required this.totalAmount,
    required this.payAmount,
    required this.discountAmount,
    required this.deliveryFee,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    this.remark,
    required this.createTime,
    this.payTime,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // 添加日志输出，方便定位问题
    String statusFromBackend = json['status'] as String? ?? '';
    debugPrint('后端返回的订单状态: $statusFromBackend');
    
    // 状态映射表
    Map<String, OrderStatus> statusMapping = {
      'PENDING_PAYMENT': OrderStatus.pendingPayment,
      'PAID': OrderStatus.paid,
      'PREPARING': OrderStatus.preparing,
      'DELIVERING': OrderStatus.delivering,
      'COMPLETED': OrderStatus.completed,
      'CANCELED': OrderStatus.canceled,
    };

    // 直接从映射表获取状态
    OrderStatus orderStatus = statusMapping[statusFromBackend] ?? OrderStatus.pendingPayment;
    debugPrint('映射后的订单状态: ${orderStatus.name}');

    return Order(
      id: json['id'],
      orderNo: json['orderNo'],
      userId: json['userId'],
      storeId: json['storeId'],
      storeName: json['storeName'] ?? '',
      storeImage: json['storeImage'] ?? '',
      status: orderStatus,
      statusDesc: json['statusDesc'] ?? '状态未知',
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      payAmount: (json['payAmount'] as num? ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] as num? ?? 0).toDouble(),
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      remark: json['remark'],
      createTime: DateTime.parse(json['createTime']),
      payTime: json['payTime'] != null ? DateTime.parse(json['payTime']) : null,
      items: (json['orderItems'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'userId': userId,
      'storeId': storeId,
      'storeName': storeName,
      'storeImage': storeImage,
      'status': status.name,
      'statusDesc': statusDesc,
      'totalAmount': totalAmount,
      'payAmount': payAmount,
      'discountAmount': discountAmount,
      'deliveryFee': deliveryFee,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverAddress': receiverAddress,
      'remark': remark,
      'createTime': createTime.toIso8601String(),
      'payTime': payTime?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // 创建副本并更新属性
  Order copyWith({
    String? id,
    String? orderNo,
    String? userId,
    String? storeId,
    String? storeName,
    String? storeImage,
    OrderStatus? status,
    String? statusDesc,
    double? totalAmount,
    double? payAmount,
    double? discountAmount,
    double? deliveryFee,
    String? receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? remark,
    DateTime? createTime,
    DateTime? payTime,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeImage: storeImage ?? this.storeImage,
      status: status ?? this.status,
      statusDesc: statusDesc ?? this.statusDesc,
      totalAmount: totalAmount ?? this.totalAmount,
      payAmount: payAmount ?? this.payAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      remark: remark ?? this.remark,
      createTime: createTime ?? this.createTime,
      payTime: payTime ?? this.payTime,
      items: items ?? this.items,
    );
  }

  // 使用状态字符串更新状态
  Order copyWithStatus(String statusStr) {
    final newStatus = OrderStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == statusStr.toUpperCase(),
      orElse: () => this.status,
    );
    return copyWith(status: newStatus);
  }

  // 计算订单中的商品总数量
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

// 订单项模型
class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? specification;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.specification,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      specification: json['specification'],
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'specification': specification,
      'subtotal': subtotal,
    };
  }
} 