///
/// 服务模块出口
///
/// 这个文件导出了所有服务类，并提供一个全局的服务定位器实例，
/// 以方便在应用各处统一访问和管理所有的服务。
library services;

/// 服务模块导出文件
/// 
/// 用于统一导出所有服务类，方便外部调用。

import 'package:get_it/get_it.dart';

export 'api_service.dart';
export 'auth_service.dart';
export 'user_service.dart';
export 'shop_service.dart';
export 'order_service.dart';
export 'promotion_service.dart';
export 'service_manager.dart';

// 提供一个快捷方式来获取服务管理器实例
import 'service_manager.dart';
ServiceManager get services => ServiceManager(); 