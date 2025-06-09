// 食品模型类
class Food {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double? originalPrice; // 原价，用于显示折扣
  final int monthSales;
  final double rating;
  final List<String> tags; // 标签，如招牌、新品等
  final String category; // 新增：食品分类

  // 构造函数
  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.originalPrice,
    required this.monthSales,
    required this.rating,
    this.tags = const [],
    required this.category,
  });

  // 从JSON解析
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      monthSales: json['month_sales'] as int,
      rating: (json['rating'] as num).toDouble(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      category: json['category'] as String? ?? '未分类',
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'original_price': originalPrice,
      'month_sales': monthSales,
      'rating': rating,
      'tags': tags,
      'category': category,
    };
  }

  // 创建副本并更新属性
  Food copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    double? price,
    double? originalPrice,
    int? monthSales,
    double? rating,
    List<String>? tags,
    String? category,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      monthSales: monthSales ?? this.monthSales,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      category: category ?? this.category,
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