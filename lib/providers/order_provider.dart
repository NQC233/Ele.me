import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/order.dart' as model;
import '../models/cart.dart';
import '../models/address.dart';
import '../models/promotion.dart';
import '../services/index.dart';
import '../services/api_service.dart';
import '../services/order_service.dart';
import '../services/promotion_service.dart';

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
  final PromotionService _promotionService = PromotionService(ApiService());

  // 订单列表
  List<model.Order> _orders = [];
  // 当前正在查看的订单
  model.Order? _currentOrder;
  // 加载状态
  bool _isLoading = false;
  // 处理状态（支付、取消等）
  bool _isProcessing = false;
  String? _error;
  List<Promotion> _availablePromotions = [];
  List<UserCoupon> _userCoupons = [];

  // 获取订单列表
  List<model.Order> get orders => _orders;

  // 获取当前订单
  model.Order? get currentOrder => _currentOrder;

  // 获取加载状态
  bool get isLoading => _isLoading;
  
  // 获取处理状态
  bool get isProcessing => _isProcessing;

  String? get error => _error;

  List<Promotion> get availablePromotions => _availablePromotions;
  
  List<UserCoupon> get userCoupons => _userCoupons;

  /// 根据用户ID获取订单列表
  Future<void> getUserOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ordersData = await _orderService.getUserOrders(userId: userId);
      _orders = ordersData.map((data) => model.Order.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('获取用户订单列表失败: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取订单详情
  Future<model.Order?> getOrderDetail(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderData = await _orderService.getOrderDetail(orderId: orderId);
      final order = model.Order.fromJson(orderData);
      _currentOrder = order;
      return order;
    } catch (e) {
      _error = e.toString();
      debugPrint('获取订单详情失败: $_error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建订单
  Future<model.Order?> createOrder({
    required String userId,
    required Cart cart,
    required Address address,
    String? remark,
    String? promotionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderData = await _orderService.createOrder(
        userId: userId,
        storeId: cart.shopId,
        items: cart.items.map((item) => {
          'productId': item.food.id,
          'productName': item.food.name,
          'price': item.food.price,
          'quantity': item.quantity,
        }).toList(),
        address: address.toJson(),
        remark: remark,
        promotionId: promotionId,
      );

      final order = model.Order.fromJson(orderData);
      _orders.insert(0, order);
      _currentOrder = order;
      return order;
    } catch (e) {
      _error = e.toString();
      debugPrint('创建订单失败: $_error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 支付订单
  Future<bool> payOrder(String orderId, String paymentMethod) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      final success = await _orderService.payOrder(
        orderId: orderId,
        paymentMethod: paymentMethod,
      );
      
      if (success && _currentOrder != null && _currentOrder!.id == orderId) {
        _currentOrder = _currentOrder!.copyWithStatus('PAID');
        
        // 更新订单列表中的状态
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWithStatus('PAID');
        }
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('支付订单失败: $_error');
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
      final success = await _orderService.cancelOrder(orderId: orderId);
      
      if (success && _currentOrder != null && _currentOrder!.id == orderId) {
        _currentOrder = _currentOrder!.copyWithStatus('CANCELLED');
        
        // 更新订单列表中的状态
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWithStatus('CANCELLED');
        }
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('取消订单失败: $_error');
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

  // 获取可用优惠
  Future<void> getAvailablePromotions({
    required String userId,
    required String storeId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? couponId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availablePromotions = await _promotionService.getOrderPromotions(
        userId: userId,
        storeId: storeId,
        totalAmount: totalAmount,
        items: items,
        couponId: couponId,
      );
      debugPrint('获取到 ${_availablePromotions.length} 个可用优惠');
    } catch (e) {
      _error = e.toString();
      debugPrint('获取可用优惠失败: $_error');
      _availablePromotions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 获取用户优惠券
  Future<void> getUserCoupons(String userId) async {
    // 先标记加载中，但不通知监听者
    _isLoading = true;
    _error = null;
    
    try {
      debugPrint('开始获取用户优惠券: userId=$userId');
      
      // 如果网络请求失败，给予三次重试机会
      int retries = 0;
      const maxRetries = 3;
      
      while (retries < maxRetries) {
        try {
          // 获取优惠券数据
          final coupons = await _promotionService.getUserCoupons(userId);
          
          // 成功获取数据后，再更新状态并通知监听者
          _userCoupons = coupons;
          _isLoading = false;
          debugPrint('成功获取 ${_userCoupons.length} 个用户优惠券');
          notifyListeners();
          return;
        } catch (e) {
          retries++;
          debugPrint('获取用户优惠券失败: $e (尝试 $retries/$maxRetries)');
          
          if (retries == maxRetries) {
            rethrow; // 最后一次重试仍失败，抛出异常
          }
          
          // 等待一段时间后重试
          await Future.delayed(Duration(milliseconds: 500 * retries));
        }
      }
    } catch (e) {
      // 出错时，设置错误信息并更新状态
      _error = e.toString();
      _userCoupons = []; // 确保即使失败也有一个空列表，而不是null
      _isLoading = false;
      debugPrint('获取用户优惠券最终失败: $_error');
      notifyListeners();
      rethrow; // 向上抛出错误，以便UI层可以显示错误信息
    }
  }

  // 清除当前订单
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}