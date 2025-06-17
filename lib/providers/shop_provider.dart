import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/shop.dart';
import '../models/food.dart';
import '../services/index.dart';
import '../services/api_service.dart';
import '../services/shop_service.dart';

///
/// 商店状态提供者 (已重构)
///
/// 负责管理商店列表、详情和菜单数据。
/// 重构后与API规范对应
///
class ShopProvider extends ChangeNotifier {
  // 服务实例
  final ShopService _shopService = ShopService(ApiService());

  // 商店列表
  List<Shop> _shops = [];
  // 当前商店
  Shop? _currentShop;
  // 当前商店菜单
  Map<String, List<Food>> _menu = {};
  // 加载状态
  bool _isLoadingShops = false;
  bool _isLoadingMenu = false;
  String? _error;

  // 获取商店列表
  List<Shop> get shops => _shops;

  // 获取当前商店
  Shop? get currentShop => _currentShop;

  // 获取当前商店菜单
  Map<String, List<Food>> get menu => _menu;

  // 获取加载状态
  bool get isLoadingShops => _isLoadingShops;
  bool get isLoadingMenu => _isLoadingMenu;
  String? get error => _error;

  // 获取附近商店列表
  Future<void> getNearbyShops({required double latitude, required double longitude, int? maxDistance}) async {
    _isLoadingShops = true;
    _error = null;
    notifyListeners();

    try {
      final shopsList = await _shopService.getNearbyShops(
        latitude: latitude, 
        longitude: longitude,
        maxDistance: maxDistance,
      );

      _shops = shopsList.map((shopData) => Shop.fromJson(shopData)).toList();
      _isLoadingShops = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingShops = false;
      notifyListeners();
      debugPrint('获取附近商店列表失败: $e');
      rethrow;
    }
  }

  // 按城市获取商店
  Future<void> getShopsByCity({required String city}) async {
    _isLoadingShops = true;
    _error = null;
    notifyListeners();

    try {
      final shopsList = await _shopService.getShopsByCity(city: city);
      _shops = shopsList.map((shopData) => Shop.fromJson(shopData)).toList();
      _isLoadingShops = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingShops = false;
      notifyListeners();
      debugPrint('按城市获取商店列表失败: $e');
      rethrow;
    }
  }

  // 按城市和区县获取商店
  Future<void> getShopsByCityAndDistrict({required String city, required String district}) async {
    _isLoadingShops = true;
    _error = null;
    notifyListeners();

    try {
      final shopsList = await _shopService.getShopsByCityAndDistrict(city: city, district: district);
      _shops = shopsList.map((shopData) => Shop.fromJson(shopData)).toList();
      _isLoadingShops = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingShops = false;
      notifyListeners();
      debugPrint('按城市和区县获取商店列表失败: $e');
      rethrow;
    }
  }

  // 获取商店详情
  Future<void> getShopDetails(String shopId) async {
    _isLoadingMenu = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('开始获取商店详情: $shopId');
      final shopDetails = await _shopService.getShopDetails(shopId: shopId);
      _currentShop = Shop.fromJson(shopDetails);
      
      _menu = {};
      
      // 处理菜单数据
      if (shopDetails.containsKey('productsByCategory')) {
        debugPrint('处理商店菜单分类数据');
        final categories = shopDetails['categories'] ?? [];
        final productsByCategory = shopDetails['productsByCategory'] ?? {};
        
        debugPrint('分类: $categories');
        debugPrint('商品分类映射: $productsByCategory');
        
        // 遍历分类，从productsByCategory中获取对应的商品列表
        if (categories is List) {
          for (var category in categories) {
            final categoryName = category.toString();
            final products = productsByCategory[categoryName];
            
            debugPrint('处理分类 $categoryName 的商品');
            
            if (products is List) {
              try {
                _menu[categoryName] = products.map((product) {
                  // 添加必要的默认值确保模型不会抛出异常
                  if (product is Map<String, dynamic>) {
                    return Food.fromJson(product);
                  } else {
                    debugPrint('无效的商品数据: $product');
                    return Food(
                      id: '',
                      storeId: shopId,
                      name: '无效商品',
                      price: 0.0,
                      category: categoryName,
                      description: '',
                      imageUrl: '',
                      status: '',
                      monthSales: 0,
                      totalSales: 0,
                    );
                  }
                }).toList();
                debugPrint('分类 $categoryName 添加了 ${_menu[categoryName]!.length} 个商品');
              } catch (e) {
                debugPrint('解析分类 $categoryName 的商品时出错: $e');
                _menu[categoryName] = [];
              }
            } else {
              _menu[categoryName] = [];
              debugPrint('分类 $categoryName 没有商品数据');
            }
          }
        }
      } else {
        // 如果没有分类数据，尝试直接获取菜单
        debugPrint('商店详情中无菜单分类数据，尝试获取菜单');
        await getShopMenu(shopId);
      }
      
      _isLoadingMenu = false;
      notifyListeners();
      debugPrint('商店详情和菜单加载完成');
    } catch (e) {
      _error = e.toString();
      _isLoadingMenu = false;
      notifyListeners();
      debugPrint('加载商店详情时出错: $e');
      // 不要再抛出异常，让UI能够显示错误信息
    }
  }

  // 获取商店菜单
  Future<void> getShopMenu(String shopId) async {
    _isLoadingMenu = true;
    if (_menu.isEmpty) {
      _menu = {};
    }
    notifyListeners();

    try {
      final menuList = await _shopService.getShopMenu(shopId: shopId);
      
      // 将菜单按分类进行分组
      for (var item in menuList) {
        try {
          final food = Food.fromJson(item);
          final category = food.category;
          
          if (!_menu.containsKey(category)) {
            _menu[category] = [];
          }
          
          _menu[category]!.add(food);
        } catch (e) {
          debugPrint('解析菜品时出错: $e');
        }
      }
      
      _isLoadingMenu = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingMenu = false;
      notifyListeners();
      debugPrint('获取商店菜单失败: $e');
      // 不要再抛出异常
    }
  }

  // 清除当前商店
  void clearCurrentShop() {
    _currentShop = null;
    _menu = {};
    _error = null;
    notifyListeners();
  }
}