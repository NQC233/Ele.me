import 'package:flutter/foundation.dart';
import 'api_service.dart';

///
/// 商店服务 (已重构)
///
/// 负责商店列表、商店详情、菜单等API请求。
/// 基于API文档规范实现，正确处理响应数据格式。
///
class ShopService {
  final ApiService _apiService;

  ShopService(this._apiService);

  /// 获取附近商店列表
  Future<List<dynamic>> getNearbyShops({required double latitude, required double longitude, int? maxDistance, int? limit}) async {
    try {
      debugPrint('获取附近商店，经度: $longitude, 纬度: $latitude');
      
      final response = await _apiService.request(
        '/stores/nearby',
        method: 'GET',
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          if (maxDistance != null) 'maxDistance': maxDistance,
          if (limit != null) 'limit': limit,
        },
      );
      
      debugPrint('获取附近商店响应: $response');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        debugPrint('获取附近商店失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      debugPrint('获取附近商店时出错: $e');
      throw Exception('获取附近商店失败: $e');
    }
  }

  /// 根据城市获取商店列表
  Future<List<dynamic>> getShopsByCity({required String city}) async {
    try {
      debugPrint('按城市获取商店，城市: $city');
      
      final response = await _apiService.request(
        '/stores/city',
        method: 'GET',
        queryParameters: {'city': city},
      );
      
      debugPrint('按城市获取商店响应: $response');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        debugPrint('按城市获取商店失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      debugPrint('按城市获取商店时出错: $e');
      throw Exception('按城市获取商店失败: $e');
    }
  }

  /// 根据城市和区县获取商店列表
  Future<List<dynamic>> getShopsByCityAndDistrict({
    required String city,
    required String district,
  }) async {
    try {
      debugPrint('按城市和区县获取商店，城市: $city，区县: $district');
      
      final response = await _apiService.request(
        '/stores/cityAndDistrict',
        method: 'GET',
        queryParameters: {
          'city': city,
          'district': district,
        },
      );
      
      debugPrint('按城市和区县获取商店响应: $response');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        debugPrint('按城市和区县获取商店失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      debugPrint('按城市和区县获取商店时出错: $e');
      throw Exception('按城市和区县获取商店失败: $e');
    }
  }

  /// 获取商店详情
  Future<Map<String, dynamic>> getShopDetails({required String shopId}) async {
    try {
      debugPrint('获取商店详情，shopId: $shopId');
      
      final response = await _apiService.request('/stores/$shopId', method: 'GET');
      
      debugPrint('获取商店详情响应: $response');
      
      if (response['success'] == true && response['data'] != null) {
        // 按规范处理嵌套的数据结构
        final shopData = response['data'];
        
        // 处理productsByCategory字段，该字段在API文档中是一个对象，key为分类名
        if (shopData is Map) {
          // 确保存在基本字段
          if (!shopData.containsKey('id')) shopData['id'] = shopId;
          if (!shopData.containsKey('name')) shopData['name'] = '未知商店';
          
          // 初始化一些可能缺失的关键字段，防止前端解析出错
          if (!shopData.containsKey('categories')) shopData['categories'] = [];
          if (!shopData.containsKey('productsByCategory')) shopData['productsByCategory'] = {};
          
          // 商品分类数据特殊处理
          final productsByCategory = shopData['productsByCategory'];
          debugPrint('商品分类数据类型: ${productsByCategory.runtimeType}');
          
          // 确保各分类下的商品数组存在且有效
          if (productsByCategory is Map && shopData['categories'] is List) {
            for (var category in shopData['categories']) {
              final categoryName = category.toString();
              if (!productsByCategory.containsKey(categoryName)) {
                productsByCategory[categoryName] = [];
              } else if (productsByCategory[categoryName] is! List) {
                productsByCategory[categoryName] = [];
              }
            }
          }
        }
        
        return shopData;
      } else {
        debugPrint('获取商店详情失败: ${response['message'] ?? '未知错误'}');
        throw Exception('商店不存在或无法获取详情');
      }
    } catch (e) {
      debugPrint('获取商店详情时出错: $e');
      throw Exception('获取商店详情失败: $e');
    }
  }

  /// 获取商店菜单
  Future<List<dynamic>> getShopMenu({required String shopId}) async {
    try {
      debugPrint('获取商店菜单，shopId: $shopId');
      
      final response = await _apiService.request('/stores/$shopId/products', method: 'GET');
      
      debugPrint('获取商店菜单响应: $response');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        debugPrint('获取商店菜单失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      debugPrint('获取商店菜单时出错: $e');
      throw Exception('获取商店菜单失败: $e');
    }
  }
  
  /// 分页获取商店菜单
  Future<Map<String, dynamic>> getShopMenuPaginated({
    required String shopId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      debugPrint('分页获取商店菜单，shopId: $shopId，页码: $page，大小: $size');
      
      final response = await _apiService.request(
        '/stores/$shopId/products/page',
        method: 'GET',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      
      debugPrint('分页获取商店菜单响应: $response');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        debugPrint('分页获取商店菜单失败: ${response['message'] ?? '未知错误'}');
        return {};
      }
    } catch (e) {
      debugPrint('分页获取商店菜单时出错: $e');
      throw Exception('分页获取商店菜单失败: $e');
    }
  }
} 