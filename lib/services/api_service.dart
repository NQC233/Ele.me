import 'dart:math';

import '../models/user.dart';
import '../models/shop.dart';
import '../models/food.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/address.dart';

///
/// 模拟API服务类
///
/// 这个类取代了原有的基于Dio的网络请求服务。它通过返回硬编码的模拟数据，
/// 模拟了与后端API的交互，使得前端可以在没有真实后端的情况下进行开发和测试。
///
/// 主要功能：
/// - 提供模拟的用户认证、商店数据、订单信息等。
/// - 所有数据都是在内存中生成和操作的，应用重启后会重置。
/// - 使用Future.delayed来模拟网络延迟，让UI能更好地处理加载状态。
///
class ApiService {
  // 单例模式
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // 在构造时就生成模拟数据，确保只生成一次
    _generateMockShops();
  }

  // 模拟网络延迟
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
  }

  // =======================================================================
  // 模拟数据区
  // 为了方便，这里直接定义了模拟数据。在真实应用中，这些数据应来自后端。
  // =======================================================================

  // 模拟一个登录用户
  final _mockUser = User(
    id: 'user-001',
    name: 'Flutter开发者',
    phone: '18888888888',
    avatar: 'https://i.pravatar.cc/150?u=user-001',
    addresses: [
      Address(
        id: 'addr-001',
        name: '王先生',
        phone: '18888888888',
        province: '上海市',
        city: '上海市',
        district: '浦东新区',
        detail: '金科路2000号',
        isDefault: true,
        tag: '公司',
      ),
      Address(
        id: 'addr-002',
        name: '王先生',
        phone: '18888888888',
        province: '上海市',
        city: '上海市',
        district: '长宁区',
        detail: '幸福路100号',
        isDefault: false,
        tag: '家',
      ),
    ],
  );

  // 模拟食品数据
  final List<Food> _mockFoods = [
    Food(id: 'food-101', name: '招牌至尊披萨', description: '经典美味，食材丰富', image: 'https://picsum.photos/seed/pizza/400/300', price: 88.0, originalPrice: 98.0, monthSales: 200, rating: 4.8, category: '热销榜'),
    Food(id: 'food-102', name: '夏威夷风情披萨', description: '菠萝与火腿的完美结合', image: 'https://picsum.photos/seed/hawaii/400/300', price: 78.0, monthSales: 150, rating: 4.7, category: '披萨意面'),
    Food(id: 'food-103', name: '经典意式肉酱面', description: '浓郁番茄，肉香四溢', image: 'https://picsum.photos/seed/pasta/400/300', price: 58.0, monthSales: 300, rating: 4.9, category: '披萨意面'),
    Food(id: 'food-104', name: '奶油蘑菇汤', description: '香滑浓郁，暖心暖胃', image: 'https://picsum.photos/seed/soup/400/300', price: 28.0, monthSales: 250, rating: 4.6, category: '汤品沙拉'),
    Food(id: 'food-105', name: '凯撒沙拉', description: '清爽健康，特制酱汁', image: 'https://picsum.photos/seed/salad/400/300', price: 38.0, monthSales: 180, rating: 4.5, category: '汤品沙拉'),
    Food(id: 'food-106', name: '黑椒牛柳意面', description: '黑椒辛香，牛肉滑嫩', image: 'https://picsum.photos/seed/beefpasta/400/300', price: 62.0, monthSales: 220, rating: 4.8, category: '披萨意面'),
    Food(id: 'food-107', name: '经典提拉米苏', description: '入口即化，甜而不腻', image: 'https://picsum.photos/seed/tiramisu/400/300', price: 35.0, monthSales: 170, rating: 4.9, category: '甜品小食'),
    Food(id: 'food-108', name: '香脆薯条', description: '外酥里嫩，金黄诱人', image: 'https://picsum.photos/seed/fries/400/300', price: 18.0, monthSales: 400, rating: 4.7, category: '甜品小食'),
  ];

  // 模拟商店列表数据
  late final List<Shop> _mockShops;

  void _generateMockShops() {
    // 移除检查，因为构造函数保证了只调用一次
    _mockShops = List.generate(10, (index) {
      final shopId = 'shop-${index + 1}';
      return Shop(
        id: shopId,
        name: '模拟美食店 ${index + 1}',
        image: 'https://picsum.photos/seed/$shopId/200/150',
        rating: 4.5 + Random().nextDouble() * 0.5,
        monthSales: 100 + Random().nextInt(5000),
        deliveryTime: 25 + Random().nextInt(15),
        deliveryFee: 2.5,
        originalDeliveryFee: 4.0,
        minOrderAmount: 20.0,
        distance: 1.0 + Random().nextDouble() * 4,
        address: '模拟地址 ${index + 1} 号',
        businessHours: ["09:00-21:00"],
        activities: ['新用户下单立减2元', '优评领3元店铺券', '返2元红包'],
        ranking: index % 3 == 0 ? '区域小吃热销榜·第${index + 1}名' : null,
        notice: '公告：欢迎光临模拟美食店 ${index + 1} 号，全场折扣进行中！',
      );
    });
  }

  // 模拟订单列表
  List<Order> _mockOrders = [];

  // =======================================================================
  // 模拟API方法
  // =======================================================================

  /// 模拟用户登录
  Future<User> login(String phone, String password) async {
    await _simulateNetworkDelay();
    // 在模拟环境中，我们直接返回用户信息，不校验密码
    if (phone == '18888888888') {
      return _mockUser;
    }
    throw Exception('用户名或密码错误');
  }

  /// 模拟获取用户个人信息
  Future<User> getUserProfile(String userId) async {
    await _simulateNetworkDelay();
    return _mockUser;
  }

  /// 模拟获取商店列表
  Future<List<Shop>> getShopList({String? category, String? sortBy}) async {
    await _simulateNetworkDelay();
    // _generateMockShops(); // 确保这里是被移除或注释掉的
    // 模拟排序和筛选
    var shops = List<Shop>.from(_mockShops);
    if (sortBy == 'distance') {
      shops.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (sortBy == 'rating') {
      shops.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return shops;
  }

  /// 模拟获取商店详情
  Future<Shop> getShopDetails(String shopId) async {
    await _simulateNetworkDelay();
    // _generateMockShops(); // 确保这里是被移除或注释掉的
    return _mockShops.firstWhere((shop) => shop.id == shopId, orElse: () => throw Exception('未找到商店'));
  }

  /// 模拟获取商店菜单列表
  Future<List<Food>> getFoodList(String shopId) async {
    await _simulateNetworkDelay();
    // 模拟不同商店有不同的菜单，这里简单返回所有食品
    // 可以通过 shopId 来过滤和返回特定的菜单
    return List<Food>.from(_mockFoods);
  }

  /// 模拟获取订单列表
  Future<List<Order>> getOrderList(String userId) async {
    await _simulateNetworkDelay();
    return List<Order>.from(_mockOrders.reversed);
  }

  /// 模拟获取单个订单详情
  Future<Order> getOrderById(String orderId) async {
    await _simulateNetworkDelay();
    return _mockOrders.firstWhere((order) => order.id == orderId, orElse: () => throw Exception('未找到订单'));
  }
  
  /// 模拟创建订单
  Future<Order> createOrder(Cart cart, Address address, String? remark) async {
    await _simulateNetworkDelay();
    final shop = await getShopDetails(cart.shopId);

    final newOrder = Order(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      shopId: cart.shopId,
      shopName: cart.shopName,
      shopImage: cart.shopImage,
      items: cart.items,
      address: address,
      foodPrice: cart.totalPrice,
      packingFee: 2.0, // 模拟包装费
      deliveryFee: shop.deliveryFee,
      discount: 5.0, // 模拟优惠
      totalPrice: cart.totalPrice + 2.0 + shop.deliveryFee - 5.0,
      status: OrderStatus.preparing, // 默认状态为准备中
      createTime: DateTime.now(),
      remark: remark,
    );

    _mockOrders.add(newOrder);
    return newOrder;
  }
} 