// 食品模型类
class Food {
  final String id;
  final String storeId;
  final String name;
  final double price;
  final String category;
  final String description;
  final String imageUrl;
  final String status;
  final int monthSales;
  final int totalSales;
  final List<String> tags;
  final double? originalPrice; // 原价，用于显示折扣
  final double? rating; // 评分可能为null

  // 构造函数
  Food({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.monthSales,
    required this.totalSales,
    this.tags = const [],
    this.originalPrice,
    this.rating,
  });

  // 从JSON解析
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      category: json['category'] ?? '未分类',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      monthSales: json['monthSales'] ?? 0,
      totalSales: json['totalSales'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'monthSales': monthSales,
      'totalSales': totalSales,
      'tags': tags,
      'original_price': originalPrice,
      'rating': rating,
    };
  }

  // 创建副本并更新属性
  Food copyWith({
    String? id,
    String? storeId,
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
    String? status,
    int? monthSales,
    int? totalSales,
    List<String>? tags,
    double? originalPrice,
    double? rating,
  }) {
    return Food(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      monthSales: monthSales ?? this.monthSales,
      totalSales: totalSales ?? this.totalSales,
      tags: tags ?? this.tags,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
    );
  }

  // 计算折扣率
  double? get discountRate {
    if (originalPrice != null && originalPrice! > 0) {
      return (1 - price / originalPrice!) * 100;
    }
    return null;
  }
} 