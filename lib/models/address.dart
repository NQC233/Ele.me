///
/// 地址模型
///
class Address {
  final String id; // 地址ID
  final String userId;
  final String receiverName;
  final String receiverPhone;
  final String province; // 省
  final String city; // 市
  final String district; // 区
  final String detail;
  final bool isDefault; // 是否为默认地址
  final String? tag; // 标签，如 '家', '公司'
  final double? longitude; // 新增字段
  final double? latitude;  // 新增字段

  Address({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.receiverPhone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    required this.isDefault,
    this.tag,
    this.longitude,
    this.latitude,
  });

  /// 从JSON创建Address对象的工厂构造函数
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['userId'],
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      province: json['province'],
      city: json['city'],
      district: json['district'],
      detail: json['detail'],
      isDefault: json['isDefault'] ?? false,
      tag: json['tag'],
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
    );
  }

  /// 将Address对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'province': province,
      'city': city,
      'district': district,
      'detail': detail,
      'isDefault': isDefault,
      'tag': tag,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  /// 获取完整的地址字符串
  String get fullAddress {
    return '$province$city$district$detail';
  }

  Address copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? receiverPhone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
    String? tag,
    double? longitude,
    double? latitude,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
      tag: tag ?? this.tag,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }
} 