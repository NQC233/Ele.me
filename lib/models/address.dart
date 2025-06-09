///
/// 地址模型
///
class Address {
  final String id; // 地址ID
  final String name; // 联系人姓名
  final String phone; // 联系电话
  final String province; // 省
  final String city; // 市
  final String district; // 区
  final String detail; // 详细地址
  final bool isDefault; // 是否为默认地址
  final String? tag; // 标签，如 '家', '公司'

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    required this.isDefault,
    this.tag,
  });

  /// 从JSON创建Address对象的工厂构造函数
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      province: json['province'],
      city: json['city'],
      district: json['district'],
      detail: json['detail'],
      isDefault: json['isDefault'] ?? false,
      tag: json['tag'],
    );
  }

  /// 将Address对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'detail': detail,
      'isDefault': isDefault,
      'tag': tag,
    };
  }

  /// 获取完整的地址字符串
  String get fullAddress {
    return '$province$city$district$detail';
  }
} 