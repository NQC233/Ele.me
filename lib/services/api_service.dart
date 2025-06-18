import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 基础API服务类
///
/// 处理HTTP请求、错误处理和令牌管理的基础类。
/// 所有专门的服务类都将使用这个基础类。
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  String? _token;
  
  final baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
  ApiService._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl, // 使用固定的baseUrl
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status! < 500; // 接受所有非500错误的状态码，让我们自己处理
      },
    );
    _dio = Dio(options);
    
    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      debugPrint('加载令牌: $_token');
      _updateAuthHeader();
    } catch (e) {
      debugPrint('加载令牌时出错: $e');
    }
  }

  void _updateAuthHeader() {
    if (_token != null && _token!.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
      debugPrint('已设置Authorization头: Bearer $_token');
    } else {
      _dio.options.headers.remove('Authorization');
      debugPrint('已移除Authorization头');
    }
  }

  void setAuthToken(String token) {
    _token = token;
    _updateAuthHeader();
    debugPrint('已更新令牌: $token');
  }

  void clearAuthToken() {
    _token = null;
    _updateAuthHeader();
    debugPrint('已清除令牌');
  }
  
  // 获取当前令牌
  String? getToken() {
    return _token;
  }

  Future<dynamic> request(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('API请求: $method $path');
      debugPrint('参数: $queryParameters');
      debugPrint('数据: $data');
      
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(path, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await _dio.post(path, data: data, queryParameters: queryParameters);
          break;
        case 'PUT':
          response = await _dio.put(path, data: data, queryParameters: queryParameters);
          break;
        case 'DELETE':
          response = await _dio.delete(path, queryParameters: queryParameters);
          break;
        default:
          throw Exception('不支持的HTTP方法: $method');
      }

      debugPrint('响应状态码: ${response.statusCode}');
      debugPrint('响应数据: ${response.data}');
      
      // 处理不同的响应情况
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 处理不同格式的成功响应
        if (response.data is Map) {
          if (response.data.containsKey('success')) {
            // 标准API响应格式
            if (response.data['success'] == true) {
              return response.data;
            } else {
              throw Exception(response.data['message'] ?? 'API请求失败');
            }
          } else if (response.data.containsKey('code') && response.data.containsKey('data')) {
            // 另一种常见格式，有code和data字段
            if (response.data['code'] == 200 || response.data['code'] == 0) {
              return {
                'success': true,
                'data': response.data['data'],
                'message': response.data['message'] ?? ''
              };
            } else {
              throw Exception(response.data['message'] ?? '请求失败，状态码：${response.data['code']}');
            }
          } else {
            // 直接返回数据，包装为统一格式
            return {'success': true, 'data': response.data};
          }
        } else {
          // 非Map类型数据，直接包装
          return {'success': true, 'data': response.data};
        }
      } else if (response.statusCode == 401) {
        // 未授权
        clearAuthToken(); // 清除无效的令牌
        throw Exception('未授权，请重新登录');
      } else {
        // 其他错误
        String errorMsg = '请求失败';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMsg = response.data['message'];
        }
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      // Dio异常处理
      debugPrint('Dio错误: $e');
      debugPrint('状态码: ${e.response?.statusCode}');
      debugPrint('响应数据: ${e.response?.data}');
      
      final error = _parseDioException(e);
      debugPrint('解析后的错误信息: $error');
      throw error;
    } catch (e) {
      // 其他未知异常
      debugPrint('未知错误: $e');
      throw 'API请求出现未知错误: $e';
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return request(path, method: 'GET', queryParameters: queryParameters);
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return request(path, method: 'POST', data: data, queryParameters: queryParameters);
  }

  // 解析Dio异常
  String _parseDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "网络连接超时，请检查网络设置";
      case DioExceptionType.sendTimeout:
        return "发送超时，请检查网络设置";
      case DioExceptionType.receiveTimeout:
        return "响应超时，请检查网络设置";
      case DioExceptionType.badResponse:
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          if (statusCode == 401) {
            return "认证失败，请重新登录";
          } else if (statusCode == 403) {
            return "您没有权限执行此操作";
          } else if (statusCode == 404) {
            return "请求的资源不存在";
          } else if (statusCode! >= 500) {
            return "服务器错误，请稍后重试";
          }
          
          if (e.response!.data is Map) {
            return e.response!.data['message'] ?? "服务器响应异常: $statusCode";
          }
          return "服务器响应异常: $statusCode";
        }
        return "服务器响应异常";
      case DioExceptionType.cancel:
        return "请求已取消";
      case DioExceptionType.unknown:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return "网络连接失败，请检查网络设置";
        }
        return "网络异常，请稍后重试";
      default:
        return "网络异常，请稍后重试";
    }
  }
} 