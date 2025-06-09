import 'package:flutter/foundation.dart';

import '../models/food.dart';
import '../models/shop.dart';
import '../services/api_service.dart';

///
/// 商店状态提供者 (已重构)
///
/// 负责管理商店相关的数据，如商店列表和当前正在查看的商店详情。
///
/// 重构后的主要变更：
/// - 所有数据获取都通过模拟的`ApiService`完成。
/// - 状态管理被简化，只在内存中保存商店列表和当前商店信息。
///
class ShopProvider extends ChangeNotifier {
  // API服务实例
  final ApiService _api = ApiService();

  // 商店列表
  List<Shop> _shops = [];
  // 当前查看的商店
  Shop? _currentShop;
  // 当前商店的菜单
  List<Food> _foods = [];
  // 是否正在加载数据
  bool _isLoading = false;
  // 是否正在加载特定商店
  bool _isFetchingDetails = false;
  // 是否正在加载菜单
  bool _isFetchingFoods = false;

  // 获取商店列表
  List<Shop> get shops => _shops;
  // 获取当前商店
  Shop? get currentShop => _currentShop;
  // 获取菜单列表
  List<Food> get foods => _foods;
  // 获取加载状态
  bool get isLoading => _isLoading;
  // 获取详情加载状态
  bool get isFetchingDetails => _isFetchingDetails;
  // 获取菜单加载状态
  bool get isFetchingFoods => _isFetchingFoods;

  /// 获取商店列表
  Future<void> fetchShops({String? sortBy}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shops = await _api.getShopList(sortBy: sortBy);
    } catch (e) {
      debugPrint('获取商店列表失败: $e');
      _shops = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 根据ID获取单个商店的详情
  Future<void> fetchShopById(String shopId) async {
    // 如果当前商店已经是目标商店，则不重复获取
    if (_currentShop?.id == shopId) return;

    _isFetchingDetails = true;
    _currentShop = null; // 先清空，以显示加载指示器
    notifyListeners();

    try {
      _currentShop = await _api.getShopDetails(shopId);
    } catch (e) {
      debugPrint('获取商店详情失败: $e');
      _currentShop = null;
    } finally {
      _isFetchingDetails = false;
      notifyListeners();
    }
  }

  /// 获取商店菜单
  Future<void> fetchFoods(String shopId) async {
    _isFetchingFoods = true;
    _foods = [];
    notifyListeners();

    try {
      _foods = await _api.getFoodList(shopId);
    } catch (e) {
      debugPrint('获取商店菜单失败: $e');
      _foods = [];
    } finally {
      _isFetchingFoods = false;
      notifyListeners();
    }
  }

  /// 清除当前商店详情和菜单
  /// 在离开商店页面时调用，以释放内存
  void clearCurrentShop() {
    _currentShop = null;
    _foods = [];
    notifyListeners();
  }
}