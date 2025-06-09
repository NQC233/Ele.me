import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../models/user.dart';
import '../models/address.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

///
/// 用户状态提供者 (已重构)
///
/// 这个Provider负责管理应用中的用户状态，如登录状态、用户信息和收货地址。
///
/// 重构后的主要变更：
/// - 移除了所有对`StorageService`的依赖，不再进行任何本地持久化操作。
/// - 简化了登录和状态管理逻辑，所有状态都只存在于内存中。
/// - 所有数据交互都通过模拟的`ApiService`完成。
///
class UserProvider extends ChangeNotifier {
  // 用户实例
  User? _user;
  // 当前选择的地址
  Address? _selectedAddress;
  // 是否正在加载数据
  bool _isLoading = false;

  // API服务实例
  final ApiService _api = ApiService();

  // 获取用户信息
  User? get user => _user;

  // 获取当前选择的地址
  Address? get selectedAddress => _selectedAddress;

  // 获取登录状态
  bool get isLoggedIn => _user != null;

  // 获取加载状态
  bool get isLoading => _isLoading;

  // 获取默认地址
  Address? get defaultAddress {
    if (_user == null || _user!.addresses.isEmpty) {
      return null;
    }
    // 尝试寻找标记为默认的地址，如果找不到，就返回第一个地址
    return _user!.addresses.firstWhere((a) => a.isDefault, orElse: () => _user!.addresses.first);
  }

  /// 使用手机号和密码登录（模拟）
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 调用模拟的登录API
      _user = await _api.login(phone, password);
      // 登录成功后，自动选择默认地址
      _selectedAddress = defaultAddress;
      return true;
    } catch (e) {
      debugPrint('登录失败: $e');
      _user = null;
      _selectedAddress = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 登出
  void logout() {
    _user = null;
    _selectedAddress = null;
    notifyListeners();
  }

  /// 选择地址
  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// 添加新地址
  void addAddress(Address newAddress) {
    if (_user == null) return;
    
    // 在内存中更新地址列表
    final updatedAddresses = List<Address>.from(_user!.addresses)..add(newAddress);
    _user = _user!.copyWith(addresses: updatedAddresses);

    // 如果新地址是默认地址或当前没有选择地址，则自动选择它
    if (newAddress.isDefault || _selectedAddress == null) {
      _selectedAddress = newAddress;
    }

    notifyListeners();
  }

  /// 更新地址
  void updateAddress(Address updatedAddress) {
    if (_user == null) return;
    
    final addresses = List<Address>.from(_user!.addresses);
    final index = addresses.indexWhere((addr) => addr.id == updatedAddress.id);
    
    if (index != -1) {
      addresses[index] = updatedAddress;
      _user = _user!.copyWith(addresses: addresses);

      // 如果更新的是当前选中的地址，也同步更新
      if (_selectedAddress?.id == updatedAddress.id) {
        _selectedAddress = updatedAddress;
      }
      notifyListeners();
    }
  }

  /// 删除地址
  void deleteAddress(String addressId) {
    if (_user == null) return;

    final addresses = _user!.addresses.where((addr) => addr.id != addressId).toList();
    _user = _user!.copyWith(addresses: addresses);
    
    // 如果删除的是当前选中的地址，则重新选择一个默认地址
    if (_selectedAddress?.id == addressId) {
      _selectedAddress = defaultAddress;
    }
    notifyListeners();
  }
} 