import 'api_service.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'shop_service.dart';
import 'order_service.dart';
import 'promotion_service.dart';

/// 服务管理器
/// 
/// 统一管理所有服务的单例类，方便在应用中访问各种服务
class ServiceManager {
  final ApiService apiService;
  final AuthService authService;
  final UserService userService;
  final ShopService shopService;
  final OrderService orderService;
  final PromotionService promotionService;

  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;

  ServiceManager._internal()
      : apiService = ApiService(),
        authService = AuthService(ApiService()),
        userService = UserService(ApiService()),
        shopService = ShopService(ApiService()),
        orderService = OrderService(ApiService()),
        promotionService = PromotionService(ApiService());

  /// 初始化服务
  /// 
  /// 在应用启动时调用此方法加载认证令牌
  Future<void> initialize() async {
    // ApiService的构造函数现在会自动加载token，
    // 所以这里不需要显式调用 loadAuthToken。
  }
}

final services = ServiceManager(); 