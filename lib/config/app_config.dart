// 应用配置文件，包含全局常量和配置信息
class AppConfig {
  // API基础URL
  static const String baseUrl = 'https://api.example.com';
  
  // APP名称
  static const String appName = '饿了么';
  
  // 默认页面大小
  static const int defaultPageSize = 10;
  
  // 超时时间（毫秒）
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  
  // 缓存有效期（分钟）
  static const int cacheExpireMinutes = 30;
} 