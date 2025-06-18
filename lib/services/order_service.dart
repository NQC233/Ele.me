import 'api_service.dart';

///
/// 订单服务 (已重构)
///
/// 负责订单创建、查询、价格计算等API请求。
///
class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  /// 获取指定用户的订单列表
  Future<List<dynamic>> getUserOrders({required String userId, String? status}) async {
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
    return response['data']['content'] ?? [];
  }

  /// 获取订单详情
  Future<Map<String, dynamic>> getOrderDetail({required String orderId}) async {
    final response = await _apiService.request('/orders/$orderId', method: 'GET');
    return response['data'];
  }

  /// 创建订单
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String storeId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> address,
    String? remark,
    String? promotionId,
  }) async {
    final response = await _apiService.request(
      '/orders',
      method: 'POST',
      data: {
        'userId': userId,
        'storeId': storeId,
        'addressId': address['id'],
        'orderItems': items,
        'remark': remark,
        'promotionId': promotionId,
      },
    );
    return response['data'];
  }

  /// 计算订单价格
  Future<Map<String, dynamic>> calculateOrderPrice({
    required String userId,
    required String storeId,
    required List<Map<String, dynamic>> items,
    required String addressId,
    String? promotionId,
  }) async {
    final response = await _apiService.request(
      '/orders/price',
      method: 'POST',
      data: {
        'userId': userId,
        'storeId': storeId,
        'addressId': addressId,
        'orderItems': items,
        'promotionId': promotionId,
      },
    );
    return response['data'];
  }

  /// 根据订单号获取订单
  /// 
  /// [orderNo] 订单号
  Future<Map<String, dynamic>> getOrderByOrderNo({required String orderNo}) async {
    final response = await _apiService.request('/orders/no/$orderNo', method: 'GET');
    return response['data'];
  }

  /// 支付订单
  /// 
  /// [orderId] 订单ID
  /// [paymentMethod] 支付方式
  Future<bool> payOrder({required String orderId, required String paymentMethod}) async {
    try {
      final response = await _apiService.request(
        '/orders/$orderId/pay',
        method: 'POST',
        data: {'paymentMethod': paymentMethod},
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// 取消订单
  /// 
  /// [orderId] 订单ID
  Future<bool> cancelOrder({required String orderId}) async {
    try {
      final response = await _apiService.request(
        '/orders/$orderId/cancel',
        method: 'POST',
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
} 