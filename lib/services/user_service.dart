import 'api_service.dart';

///
/// 用户服务 (已重构)
///
/// 负责用户个人资料、地址管理等API请求。
///
class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// 获取当前登录用户的个人资料
  Future<Map<String, dynamic>> getUserProfile() async {
    // 假设token验证后，后端通过token能识别用户，所以不需要传userId
    final response = await _apiService.request('/api/users/profile', method: 'GET');
    return response['data'];
  }

  /// 获取指定用户的地址列表
  Future<List<dynamic>> getAddresses({required String userId}) async {
    final response = await _apiService.request('/api/users/$userId/addresses', method: 'GET');
    return response['data'];
  }

  /// 为指定用户添加新地址
  Future<Map<String, dynamic>> addAddress({required String userId, required Map<String, dynamic> addressData}) async {
    // 根据API定义，POST到 /api/users/{userId}/addresses
    final response = await _apiService.request(
      '/api/users/$userId/addresses',
      method: 'POST',
      data: addressData,
    );
    return response['data'];
  }

  /// 更新指定用户的地址
  Future<Map<String, dynamic>> updateAddress({required String userId, required String addressId, required Map<String, dynamic> addressData}) async {
    final response = await _apiService.request(
      '/api/users/$userId/addresses/$addressId',
      method: 'PUT',
      data: addressData,
    );
    return response['data'];
  }

  /// 删除指定用户的地址
  Future<bool> deleteAddress({required String userId, required String addressId}) async {
    try {
      await _apiService.request(
        '/api/users/$userId/addresses/$addressId',
        method: 'DELETE',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 设置指定用户的默认地址
  Future<Map<String, dynamic>> setDefaultAddress({required String userId, required String addressId}) async {
    final response = await _apiService.request(
      '/api/users/$userId/addresses/$addressId/default',
      method: 'PUT',
    );
    return response['data'];
  }
} 