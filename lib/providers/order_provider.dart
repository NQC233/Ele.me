import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../services/api_service.dart';

///
/// 订单状态提供者 (已重构)
///
/// 负责管理用户的订单数据，包括获取订单列表和创建新订单。
///
/// 重构后的主要变更：
/// - 移除了分页和复杂的错误处理逻辑，简化了状态管理。
/// - 所有数据交互都通过模拟的`ApiService`完成。
///
class OrderProvider extends ChangeNotifier {
  // API服务实例
  final ApiService _api = ApiService();

  // 订单列表
  List<Order> _orders = [];
  // 当前正在查看的订单
  Order? _currentOrder;
  // 加载状态
  bool _isLoading = false;

  // 获取订单列表
  List<Order> get orders => _orders;

  // 获取当前订单
  Order? get currentOrder => _currentOrder;

  // 获取加载状态
  bool get isLoading => _isLoading;

  /// 根据用户ID获取订单列表
  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 调用模拟API获取订单
      _orders = await _api.getOrderList(userId);
    } catch (e) {
      debugPrint('获取订单列表失败: $e');
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 根据订单ID获取单个订单详情
  Future<void> fetchOrderById(String orderId) async {
    _isLoading = true;
    _currentOrder = null; // 先清空旧数据
    notifyListeners();

    try {
      _currentOrder = await _api.getOrderById(orderId);
    } catch (e) {
      debugPrint('获取订单详情失败: $e');
      _currentOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建新订单
  Future<Order?> createOrder({
    required Cart cart,
    required Address address,
    String? remark,
  }) async {
    if (cart.items.isEmpty) {
      debugPrint('创建订单失败：购物车为空');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 调用模拟API创建订单
      final newOrder = await _api.createOrder(cart, address, remark);
      
      // 将新订单添加到列表顶部
      _orders.insert(0, newOrder);
      
      return newOrder;
    } catch (e) {
      debugPrint('创建订单失败: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 根据状态筛选订单
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// 清空订单列表 (例如，在用户登出时调用)
  void clearOrders() {
    _orders = [];
    notifyListeners();
  }
} 