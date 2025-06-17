import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user.dart';
import '../models/address.dart';
import '../services/index.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

///
/// 用户状态提供者 (已重构)
///
/// 这个Provider负责管理应用中的用户状态，如登录状态、用户信息和收货地址。
///
/// 重构后的主要变更：
/// - 使用新的AuthService和UserService替换旧的ApiService
/// - 采用真实API调用而非模拟数据
/// - 保留完整的用户状态管理逻辑
///
class UserProvider extends ChangeNotifier {
  User? _user;
  List<Address> _addresses = [];
  Address? _defaultAddress;
  bool _isLoading = false;
  String? _error;
  String? _token;

  final AuthService _authService = AuthService(ApiService());
  final UserService _userService = UserService(ApiService());

  User? get user => _user;
  List<Address> get addresses => _addresses;
  Address? get defaultAddress => _defaultAddress;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider() {
    _loadUserFromPrefs();
  }

  Address? _getNewDefaultAddress() {
    if (_addresses.isEmpty) return null;
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return _addresses.first;
    }
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userDataString = prefs.getString('user');

    if (token != null && userDataString != null) {
      _token = token;
      _user = User.fromJson(json.decode(userDataString));
      ApiService().setAuthToken(token);
      await fetchAddresses();
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(user.toJson()));
  }

  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<bool> login(String credential, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      debugPrint('开始登录流程, 凭证: $credential');
      
      final response = await _authService.login(credential, password);
      debugPrint('AuthService登录响应: $response');
      
      if (response.containsKey('data')) {
        final Map<String, dynamic> userData = response['data'];
        
        if (userData.containsKey('user') && userData.containsKey('token')) {
          _user = User.fromJson(userData['user']);
          _token = userData['token'];
          
          debugPrint('保存用户数据: $_user');
          debugPrint('令牌: $_token');
          
          ApiService().setAuthToken(_token!);
          await _saveUserToPrefs(_user!, _token!);
          await fetchAddresses(); // 获取地址列表
          
          return true;
        }
      }
      
      _error = '无效的登录响应格式';
      debugPrint('登录失败: $_error');
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('登录过程中出现异常: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_user != null) {
      await _authService.logout(_user!.id);
    }
    _user = null;
    _token = null;
    _addresses = [];
    _defaultAddress = null;
    ApiService().clearAuthToken();
    await _clearUserFromPrefs();
    notifyListeners();
  }

  Future<void> fetchAddresses() async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final addressesData = await _userService.getAddresses(userId: _user!.id);
      _addresses = addressesData.map((data) => Address.fromJson(data)).toList();
      _defaultAddress = _getNewDefaultAddress();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(Address address) async {
     if (_user == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final newAddressMap = await _userService.addAddress(userId: _user!.id, addressData: address.toJson());
      final newAddress = Address.fromJson(newAddressMap);
      _addresses.add(newAddress);
      if (newAddress.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          if (_addresses[i].id != newAddress.id) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
        _defaultAddress = newAddress;
      }
      return true;
    } catch (e) {
       _error = e.toString();
       return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(Address address) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedAddressMap = await _userService.updateAddress(userId: _user!.id, addressId: address.id, addressData: address.toJson());
      final updatedAddress = Address.fromJson(updatedAddressMap);
      final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        if(updatedAddress.isDefault) {
           _defaultAddress = updatedAddress;
        } else if (_defaultAddress?.id == updatedAddress.id) {
          _defaultAddress = _getNewDefaultAddress();
        }
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final originalAddresses = List<Address>.from(_addresses);
    _addresses.removeWhere((addr) => addr.id == addressId);
    notifyListeners();

    try {
      final success = await _userService.deleteAddress(userId: user!.id, addressId: addressId);
      if (!success) {
        _addresses = originalAddresses;
        notifyListeners();
      } else {
        // 如果删除的是默认地址，则重新选择一个
        if (defaultAddress?.id == addressId) {
          _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
        }
      }
    } catch (e) {
      _addresses = originalAddresses;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
     if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.setDefaultAddress(userId: _user!.id, addressId: addressId);
      await fetchAddresses();
    } catch (e) {
       _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    _defaultAddress = address;
    notifyListeners();
  }
}

extension AddressCopyWith on Address {
    Address copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? receiverPhone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
    String? tag,
    double? longitude,
    double? latitude,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
      tag: tag ?? this.tag,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }
} 