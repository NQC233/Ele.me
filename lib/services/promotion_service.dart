import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/promotion.dart';
import 'package:dio/dio.dart';

/// 优惠服务类
/// 
/// 处理优惠信息和优惠券
class PromotionService {
  final ApiService _apiService;

  PromotionService(this._apiService);

  /// 获取用户特定订单的可用优惠信息 (用于结算页面)
  /// 
  /// [userId] 用户ID
  /// [storeId] 商店ID
  /// [totalAmount] 订单总金额
  /// [items] 订单商品列表，每个项目需要包含productId、productName、price和quantity
  /// [couponId] 可选的优惠券ID
  Future<List<Promotion>> getOrderPromotions({
    required String userId,
    required String storeId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? couponId,
  }) async {
    final response = await _apiService.request(
      '/promotions/user/order-promotions',
      method: 'POST',
      data: {
        'userId': userId,
        'storeId': storeId,
        'totalAmount': totalAmount,
        'items': items,
        if (couponId != null) 'couponId': couponId,
      },
    );
    
    final List<dynamic> promotionsData = response['data'] ?? [];
    return promotionsData.map((data) => Promotion.fromJson(data)).toList();
  }
  
  /// 获取用户的所有可用优惠券 (用于用户中心)
  ///
  /// [userId] 用户ID
  Future<List<UserCoupon>> getUserCoupons(String userId) async {
    try {
      // 直接使用ApiService的request方法，确保授权已正确设置
      final response = await _apiService.request(
        '/promotions/user/coupons',
        method: 'GET',
        queryParameters: {'userId': userId},
      );

      debugPrint('获取用户优惠券成功，解析数据...');
      
      if (response.containsKey('data')) {
        final List<dynamic> couponsData = response['data'] ?? [];
        final List<UserCoupon> coupons = [];
        
        for (var data in couponsData) {
          try {
            coupons.add(UserCoupon.fromJson(data));
          } catch (e) {
            debugPrint('解析优惠券数据失败: $e, 数据: $data');
          }
        }
        
        debugPrint('成功解析了 ${coupons.length} 张优惠券');
        return coupons;
      } else {
        debugPrint('响应数据格式不符合预期: $response');
        return [];
      }
    } catch (e) {
      debugPrint('获取用户优惠券时出现异常: $e');
      // 即使出错也返回空列表，避免前端崩溃
      rethrow; // 重新抛出异常，让调用者处理
    }
  }
  
  /// 获取店铺的所有可用优惠活动 (用于商店页面)
  ///
  /// [storeId] 店铺ID
  Future<List<Promotion>> getStoreActivities(String storeId) async {
    final response = await _apiService.request(
      '/promotions/store/activities',
      method: 'GET',
      queryParameters: {
        'storeId': storeId,
      },
    );
    
    final List<dynamic> activitiesData = response['data'] ?? [];
    return activitiesData.map((data) => Promotion.fromJson(data)).toList();
  }
} 