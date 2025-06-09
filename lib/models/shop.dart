import 'food.dart';

// 商家模型类
class Shop {
  final String id;
  final String name;
  final String image;
  final double rating;
  final int monthSales;
  final int deliveryTime;
  final double deliveryFee;
  final double? originalDeliveryFee; // 新增：原配送费
  final double minOrderAmount;
  final double distance;
  final List<String> activities; // 优惠活动
  final String? ranking; // 新增：榜单信息
  final String notice; // 新增：商家公告
  final bool isFavorite;
  final String address;
  final List<String> businessHours;

  // 构造函数
  Shop({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.monthSales,
    required this.deliveryTime,
    required this.deliveryFee,
    this.originalDeliveryFee,
    required this.minOrderAmount,
    required this.distance,
    this.activities = const [],
    this.ranking,
    required this.notice,
    this.isFavorite = false,
    required this.address,
    required this.businessHours,
  });

  // 从JSON解析
  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num).toDouble(),
      monthSales: json['month_sales'] as int,
      deliveryTime: json['delivery_time'] as int,
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      originalDeliveryFee: (json['original_delivery_fee'] as num?)?.toDouble(),
      minOrderAmount: (json['min_order_amount'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      activities: json['activities'] != null
          ? List<String>.from(json['activities'])
          : [],
      ranking: json['ranking'] as String?,
      notice: json['notice'] as String? ?? '欢迎光临，很高兴为您服务！',
      isFavorite: json['is_favorite'] as bool? ?? false,
      address: json['address'] as String,
      businessHours: json['business_hours'] != null
          ? List<String>.from(json['business_hours'])
          : [],
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'month_sales': monthSales,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'original_delivery_fee': originalDeliveryFee,
      'min_order_amount': minOrderAmount,
      'distance': distance,
      'activities': activities,
      'ranking': ranking,
      'notice': notice,
      'is_favorite': isFavorite,
      'address': address,
      'business_hours': businessHours,
    };
  }

  // 创建副本并更新属性
  Shop copyWith({
    String? id,
    String? name,
    String? image,
    double? rating,
    int? monthSales,
    int? deliveryTime,
    double? deliveryFee,
    double? originalDeliveryFee,
    double? minOrderAmount,
    double? distance,
    List<String>? activities,
    String? ranking,
    String? notice,
    bool? isFavorite,
    String? address,
    List<String>? businessHours,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      monthSales: monthSales ?? this.monthSales,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      originalDeliveryFee: originalDeliveryFee ?? this.originalDeliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      distance: distance ?? this.distance,
      activities: activities ?? this.activities,
      ranking: ranking ?? this.ranking,
      notice: notice ?? this.notice,
      isFavorite: isFavorite ?? this.isFavorite,
      address: address ?? this.address,
      businessHours: businessHours ?? this.businessHours,
    );
  }
}

// 食品分类模型类
class FoodCategory {
  final String id;
  final String name;
  final List<Food> foods;

  // 构造函数
  FoodCategory({
    required this.id,
    required this.name,
    this.foods = const [],
  });

  // 从JSON解析
  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    List<Food> foodList = [];
    if (json['foods'] != null) {
      foodList = List<Food>.from(
        json['foods'].map((food) => Food.fromJson(food)),
      );
    }

    return FoodCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      foods: foodList,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'foods': foods.map((food) => food.toJson()).toList(),
    };
  }

  // 创建副本并更新属性
  FoodCategory copyWith({
    String? id,
    String? name,
    List<Food>? foods,
  }) {
    return FoodCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      foods: foods ?? this.foods,
    );
  }
} 