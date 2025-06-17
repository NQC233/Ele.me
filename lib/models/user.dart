class User {
  final String id;
  final String username;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String createdAt;
  final List<String> addresses;

  // 构造函数
  User({
    required this.id,
    required this.username,
    this.phone,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    this.addresses = const [],
  });

  // 从JSON解析
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] as String,
      addresses: json['addresses'] != null 
          ? List<String>.from(json['addresses']) 
          : [],
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'addresses': addresses,
    };
  }

  // 创建副本并更新属性
  User copyWith({
    String? id,
    String? username,
    String? phone,
    String? email,
    String? avatarUrl,
    String? createdAt,
    List<String>? addresses,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      addresses: addresses ?? this.addresses,
    );
  }
} 