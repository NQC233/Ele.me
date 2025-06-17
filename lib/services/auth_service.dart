import 'package:flutter/foundation.dart';
import 'api_service.dart';

///
/// 认证服务 (已重构)
///
/// 负责处理用户登录、注册、注销等所有与认证相关的API请求。
///
class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// 用户登录
  Future<Map<String, dynamic>> login(String credential, String password) async {
    try {
      debugPrint('开始登录，凭证: $credential');
      
      final response = await _apiService.request(
        '/api/users/login',
        method: 'POST',
        data: {
          'credential': credential,
          'password': password,
        },
      );
      
      debugPrint('登录响应: $response');
      
      // 检查响应结构
      if (response != null && response['data'] != null) {
        // 后端直接返回用户数据，无需额外的嵌套
        final userData = response['data'];
        final token = userData['token'];
        
        if (token != null) {
          // 返回格式与UserProvider期望的格式一致
          return {
            'data': {
              'user': userData,
              'token': token
            }
          };
        }
      }
      
      // 如果代码执行到这里，说明响应格式不正确
      debugPrint('登录失败: 响应格式不正确');
      throw Exception('登录响应格式不正确');
    } catch (e) {
      debugPrint('登录过程中出现异常: $e');
      throw Exception('登录失败: $e');
    }
  }

  /// 用户注册
  /// 
  /// [username] 用户名
  /// [password] 密码
  /// [phone] 可选的手机号
  /// [email] 可选的邮箱
  /// [realName] 可选的真实姓名
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? phone,
    String? email,
    String? realName,
  }) async {
    return await _apiService.post('/api/users/register', data: {
      'username': username,
      'password': password,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (realName != null) 'realName': realName,
    });
  }

  /// 用户注销
  /// 
  /// [userId] 用户ID
  Future<bool> logout(String userId) async {
    try {
      final response = await _apiService.post('/api/auth/logout/$userId');
      return response['success'] == true;
    } catch (e) {
      debugPrint('注销失败: $e');
      return false;
    }
  }
  
  /// 验证令牌
  /// 
  /// [token] 认证令牌
  Future<bool> verifyToken(String token) async {
    try {
      final response = await _apiService.post('/api/auth/verify', data: {
        'token': token,
      });
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
} 