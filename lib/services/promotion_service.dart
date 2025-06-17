import 'api_service.dart';

/// 优惠服务类
/// 
/// 处理优惠信息和优惠券
class PromotionService {
  final ApiService _apiService;

  PromotionService(this._apiService);

  /// 获取可用优惠
  /// 
  /// [userId] 用户ID
  /// [storeId] 商店ID
  /// [totalAmount] 订单总金额
  /// [items] 订单商品列表，每个项目需要包含productId、productName、price和quantity
  /// [couponId] 可选的优惠券ID
  Future<List<dynamic>> getApplicablePromotions({
    required String userId,
    required String storeId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? couponId,
  }) async {
    final response = await _apiService.request(
      '/promotions/applicable',
      method: 'POST',
      data: {
        'userId': userId,
        'storeId': storeId,
        'totalAmount': totalAmount,
        'items': items,
        if (couponId != null) 'couponId': couponId,
      },
    );
    return response['data'];
  }
} 