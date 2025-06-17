import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/order.dart' as model;
import '../models/cart.dart';
import '../models/address.dart';
import '../services/index.dart';
import '../services/api_service.dart';

///
/// 订单状态提供者 (已重构)
///
/// 负责管理用户的订单数据，包括获取订单列表和创建新订单。
///
/// 重构后的主要变更：
/// - 使用新的OrderService替换旧的ApiService
/// - 处理真实API的响应结构，并适配到应用模型
/// - 添加了订单支付和取消功能
///
class OrderProvider extends ChangeNotifier {
  // 服务实例
  final OrderService _orderService = OrderService(ApiService());

  // 订单列表
  List<model.Order> _orders = [];
  // 当前正在查看的订单
  model.Order? _currentOrder;
  // 加载状态
  bool _isLoading = false;
  // 处理状态（支付、取消等）
  bool _isProcessing = false;
  String? _error;

  // 获取订单列表
  List<model.Order> get orders => _orders;

  // 获取当前订单
  model.Order? get currentOrder => _currentOrder;

  // 获取加载状态
  bool get isLoading => _isLoading;
  
  // 获取处理状态
  bool get isProcessing => _isProcessing;

  String? get error => _error;

  /// 根据用户ID获取订单列表
  Future<void> fetchOrders(String userId, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ordersData = await _orderService.getOrders(userId: userId, status: status);
      _orders = ordersData.map((data) => model.Order.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
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
      final orderData = await _orderService.getOrderDetail(orderId: orderId);
      _currentOrder = model.Order.fromJson(orderData);
    } catch (e) {
      debugPrint('获取订单详情失败: $e');
      _currentOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 根据订单号获取订单详情
  Future<void> fetchOrderByOrderNo(String orderNo) async {
    _isLoading = true;
    _currentOrder = null; // 先清空旧数据
    notifyListeners();

    try {
      final orderData = await _orderService.getOrderByOrderNo(orderNo);
      _currentOrder = model.Order.fromJson(orderData);
    } catch (e) {
      debugPrint('获取订单详情失败: $e');
      _currentOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建新订单
  Future<model.Order?> createOrder({
    required String userId,
    required Cart cart,
    required Address address,
    String? remark,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOrderData = await _orderService.createOrder(
        userId: userId,
        cart: cart,
        address: address,
        remark: remark,
      );
      final newOrder = model.Order.fromJson(newOrderData);
      _orders.insert(0, newOrder);
      _currentOrder = newOrder;
      return newOrder;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 支付订单
  Future<bool> payOrder(String orderNo) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      final orderData = await _orderService.payOrder(orderNo);
      // 更新订单状态
      _updateOrderInList(orderData);
      return true;
    } catch (e) {
      debugPrint('支付订单失败: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// 取消订单
  Future<bool> cancelOrder(String orderId) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      final orderData = await _orderService.cancelOrder(orderId);
      // 更新订单状态
      _updateOrderInList(orderData);
      return true;
    } catch (e) {
      debugPrint('取消订单失败: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// 将API返回的订单数据更新到列表中
  void _updateOrderInList(Map<String, dynamic> orderData) {
    final orderId = orderData['id'];
    if (orderId != null) {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = model.Order.fromJson(orderData);
        // 如果当前正在查看这个订单，也更新当前订单
        if (_currentOrder?.id == orderId) {
          _currentOrder = _orders[index];
        }
      }
    }
  }

  /// 按状态筛选订单
  List<model.Order> getOrdersByStatus(model.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// 清空订单列表 (例如，在用户登出时调用)
  void clearOrders() {
    _orders.clear();
    _currentOrder = null;
    notifyListeners();
  }

  // 根据订单ID获取订单详情
  Future<model.Order?> getOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderData = await _orderService.getOrderDetail(orderId: orderId);
      _currentOrder = model.Order.fromJson(orderData);
      return _currentOrder;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 模拟计算订单价格
  Future<Map<String, dynamic>?> calculateOrderPrice({
    required Cart cart,
    required String addressId,
    String? couponId,
  }) async {
    // 在真实应用中，这里应该调用API
    // 此处仅为模拟
    try {
      // 假设的API调用
      // final priceDetails = await _orderService.calculatePrice(...);
      // return priceDetails;
      
      // 模拟返回
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'totalAmount': cart.totalPrice + 5.0, // 商品总价 + 运费
        'payAmount': cart.totalPrice + 5.0 - 2.0, // 假设优惠2元
        'discountAmount': 2.0,
        'deliveryFee': 5.0,
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}