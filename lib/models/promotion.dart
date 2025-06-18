/// 优惠信息模型类
class Promotion {
  final String id;
  final String type; // ACTIVITY(活动)、COUPON(优惠券)
  final String title;
  final String description;
  final double discountAmount;
  final double? afterDiscountPrice; // 优惠后价格
  final String? conditions; // 使用条件描述
  final bool? selected; // 是否已选择
  final int priority; // 优先级，数字越小优先级越高

  Promotion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.discountAmount,
    this.afterDiscountPrice,
    this.conditions,
    this.selected,
    required this.priority,
  });

  // 从JSON解析
  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      type: json['type'] ?? 'ACTIVITY',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountAmount: json['discountAmount'] != null 
          ? (json['discountAmount'] as num).toDouble() 
          : 0.0,
      afterDiscountPrice: json['afterDiscountPrice'] != null
          ? (json['afterDiscountPrice'] as num).toDouble()
          : null,
      conditions: json['conditions'],
      selected: json['selected'],
      priority: json['priority'] ?? 0,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'discountAmount': discountAmount,
      'afterDiscountPrice': afterDiscountPrice,
      'conditions': conditions,
      'selected': selected,
      'priority': priority,
    };
  }
}

/// 用户优惠券模型类
/// 
/// 用于展示用户拥有的优惠券信息
class UserCoupon {
  final String id;
  final String title;
  final String description;
  final double discountAmount;
  final double threshold;
  final String storeId;
  final String storeName;
  final String validUntil;
  final String status; // UNUSED(可用)、USED(已使用)、EXPIRED(已过期)
  final String ruleTypeDesc; // 规则类型描述：满减券、折扣券等

  UserCoupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discountAmount,
    required this.threshold,
    required this.storeId,
    required this.storeName,
    required this.validUntil,
    required this.status,
    required this.ruleTypeDesc,
  });

  // 从JSON解析
  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    return UserCoupon(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountAmount: json['discountAmount'] != null
          ? (json['discountAmount'] as num).toDouble()
          : 0.0,
      threshold: json['threshold'] != null
          ? (json['threshold'] as num).toDouble()
          : 0.0,
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      validUntil: json['validUntil'] ?? '',
      status: json['status'] ?? 'UNUSED',
      ruleTypeDesc: json['ruleTypeDesc'] ?? '',
    );
  }

  // 是否可用
  bool get isUsable => status == 'UNUSED';

  // 是否已过期
  bool get isExpired => status == 'EXPIRED';

  // 是否已使用
  bool get isUsed => status == 'USED';
} 