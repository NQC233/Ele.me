import 'address.dart';

// 用户模型类
class User {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final String? email;
  final List<Address> addresses;

  // 构造函数
  User({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.email,
    this.addresses = const [],
  });

  // 从JSON解析
  factory User.fromJson(Map<String, dynamic> json) {
    List<Address> addressList = [];
    if (json['addresses'] != null) {
      addressList = List<Address>.from(
        json['addresses'].map((address) => Address.fromJson(address)),
      );
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      addresses: addressList,
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'email': email,
      'addresses': addresses.map((address) => address.toJson()).toList(),
    };
  }

  // 创建副本并更新属性
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    String? email,
    List<Address>? addresses,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
    );
  }
} 