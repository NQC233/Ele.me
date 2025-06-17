import 'dart:convert';
import 'food.dart';

/// 商店模型 (根据openapi.json重构)
class Shop {
  final String id;
  final String name;
  final String logoUrl;
  final String? status;
  final double minimumOrderAmount; // 最低起送价
  final double deliveryFee; // 配送费
  final int estimatedDeliveryTime; // 预计配送时间(分钟)
  final double? averageRating; // 平均评分
  final int? monthSales; // 月销量
  final int? distance; // 距离用户的距离(米)
  
  // 详情信息
  final String? province;
  final String? city;
  final String? district;
  final String? street;
  final String? detail; // 详细地址
  final String? longitude;
  final String? latitude;
  final String? notice; // 公告
  final Map<String, dynamic>? businessHours; // 营业时间
  final String? businessHoursJson; // 营业时间JSON字符串
  final int? deliveryRange; // 配送范围(米)
  final int? totalRatingCount; // 总评分数
  final List<String>? images; // 门店图片
  final List<String>? categories; // 分类列表

  Shop({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.status,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    required this.estimatedDeliveryTime,
    this.averageRating,
    this.monthSales,
    this.distance,
    this.province,
    this.city,
    this.district,
    this.street,
    this.detail,
    this.longitude,
    this.latitude,
    this.notice,
    this.businessHours,
    this.businessHoursJson,
    this.deliveryRange,
    this.totalRatingCount,
    this.images,
    this.categories,
  });

  String get address => '$province$city$district${street ?? ''}$detail';

  // 获取格式化的营业时间
  List<String> getBusinessHoursList() {
    // 先尝试使用businessHours对象
    if (businessHours != null && businessHours!.isNotEmpty) {
      return businessHours!.entries.map((e) => '${e.key}: ${e.value}').toList();
    }
    
    // 如果没有businessHours对象，尝试解析businessHoursJson
    if (businessHoursJson != null && businessHoursJson!.isNotEmpty) {
      try {
        final decoded = json.decode(businessHoursJson!);
        if (decoded is Map) {
          return decoded.entries.map((e) => '${e.key}: ${e.value}').toList();
        } else if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
        return [decoded.toString()];
      } catch (e) {
        return [businessHoursJson!]; // 如果解析失败，直接返回原始字符串
      }
    }
    
    return ['暂无营业时间信息'];
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    // 处理可能的不同类型，确保转换正确
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is double) return value;
      return 0.0;
    }
    
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }
    
    // 解析营业时间，可能是对象或JSON字符串
    Map<String, dynamic>? parsedBusinessHours;
    String? rawBusinessHoursJson = json['businessHoursJson'] as String?;
    
    // 如果API返回了完整对象businessHours，直接使用
    if (json['businessHours'] is Map) {
      parsedBusinessHours = Map<String, dynamic>.from(json['businessHours'] as Map);
    }
    
    // 图片URL列表处理
    List<String>? parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value.map((v) => v.toString()));
      return [];
    }

    return Shop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      status: json['status'],
      minimumOrderAmount: parseDouble(json['minimumOrderAmount']),
      deliveryFee: parseDouble(json['deliveryFee']),
      estimatedDeliveryTime: parseInt(json['estimatedDeliveryTime']),
      averageRating: parseDouble(json['averageRating']),
      monthSales: parseInt(json['monthSales']),
      distance: parseInt(json['distance']),
      province: json['province'],
      city: json['city'],
      district: json['district'],
      street: json['street'],
      detail: json['detail'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      notice: json['notice'],
      businessHours: parsedBusinessHours,
      businessHoursJson: rawBusinessHoursJson,
      deliveryRange: parseInt(json['deliveryRange']),
      totalRatingCount: parseInt(json['totalRatingCount']),
      images: parseStringList(json['images']),
      categories: parseStringList(json['categories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'status': status,
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'averageRating': averageRating,
      'monthSales': monthSales,
      'distance': distance,
      'province': province,
      'city': city,
      'district': district,
      'street': street,
      'detail': detail,
      'longitude': longitude,
      'latitude': latitude,
      'notice': notice,
      'businessHours': businessHours,
      'businessHoursJson': businessHoursJson,
      'deliveryRange': deliveryRange,
      'totalRatingCount': totalRatingCount,
      'images': images,
      'categories': categories,
    };
  }

  Shop copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? status,
    double? minimumOrderAmount,
    double? deliveryFee,
    int? estimatedDeliveryTime,
    double? averageRating,
    int? monthSales,
    int? distance,
    String? province,
    String? city,
    String? district,
    String? street,
    String? detail,
    String? longitude,
    String? latitude,
    String? notice,
    Map<String, dynamic>? businessHours,
    String? businessHoursJson,
    int? deliveryRange,
    int? totalRatingCount,
    List<String>? images,
    List<String>? categories,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      averageRating: averageRating ?? this.averageRating,
      monthSales: monthSales ?? this.monthSales,
      distance: distance ?? this.distance,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
      detail: detail ?? this.detail,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      notice: notice ?? this.notice,
      businessHours: businessHours ?? this.businessHours,
      businessHoursJson: businessHoursJson ?? this.businessHoursJson,
      deliveryRange: deliveryRange ?? this.deliveryRange,
      totalRatingCount: totalRatingCount ?? this.totalRatingCount,
      images: images ?? this.images,
      categories: categories ?? this.categories,
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