import 'api_service.dart';
import '../models/cart.dart';
import '../models/address.dart';

///
/// 订单服务 (已重构)
///
/// 负责订单创建、查询、价格计算等API请求。
///
class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  /// 获取指定用户的订单列表
  Future<List<dynamic>> getOrders({required String userId, String? status}) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await _apiService.request(
      '/orders/user/$userId',
      method: 'GET',
      queryParameters: queryParams,
    );
    // API返回的是分页数据，我们提取content
    return response['data']['content'];
  }

  /// 获取订单详情
  Future<Map<String, dynamic>> getOrderDetail({required String orderId}) async {
    final response = await _apiService.request('/orders/$orderId', method: 'GET');
    return response['data'];
  }

  /// 创建订单
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required Cart cart,
    required Address address,
    String? remark,
    String? couponId,
  }) async {
    final orderItems = cart.items.map((item) => {
      'productId': item.food.id,
      'quantity': item.quantity,
    }).toList();

    final response = await _apiService.request(
      '/orders',
      method: 'POST',
      data: {
        'userId': userId,
        'storeId': cart.shopId,
        'addressId': address.id,
        'orderItems': orderItems,
        'remark': remark,
        'couponId': couponId,
      },
    );
    return response['data'];
  }

  /// 计算订单价格
  Future<Map<String, dynamic>> calculateOrderPrice({
    required String userId,
    required Cart cart,
    required String addressId,
    String? couponId,
  }) async {
    final orderItems = cart.items.map((item) => {
      'productId': item.food.id,
      'quantity': item.quantity,
    }).toList();

    final response = await _apiService.request(
      '/orders/price',
      method: 'POST',
      data: {
        'userId': userId,
        'storeId': cart.shopId,
        'addressId': addressId,
        'orderItems': orderItems,
        'couponId': couponId,
      },
    );
    return response['data'];
  }

  /// 根据订单号获取订单
  /// 
  /// [orderNo] 订单号
  Future<Map<String, dynamic>> getOrderByOrderNo(String orderNo) async {
    final response = await _apiService.get('/orders/no/$orderNo');
    return response['data'];
  }

  /// 支付订单
  /// 
  /// [orderNo] 订单号
  Future<Map<String, dynamic>> payOrder(String orderNo) async {
    final response = await _apiService.post('/orders/$orderNo/pay');
    return response['data'];
  }

  /// 取消订单
  /// 
  /// [orderId] 订单ID
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final response = await _apiService.post('/orders/$orderId/cancel');
    return response['data'];
  }
} 