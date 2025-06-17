# 后端API接口分析与前端需求接口记录

## 用户认证与账户管理接口
1. **用户认证**
   - 登录: `/api/users/login` (POST)
   - 注册: `/api/users/register` (POST)
   - 注销: `/api/auth/logout/{userId}` (POST)
   - 获取用户信息: `/api/users/{userId}` (GET)

2. **地址管理**
   - 获取地址列表: `/api/users/{userId}/addresses` (GET)
   - 删除地址: `/api/users/{userId}/addresses/{addressId}` (DELETE)
   - 设置默认地址: `/api/users/{userId}/addresses/{addressId}/default` (PUT)
   - 获取默认地址: `/api/users/{userId}/addresses/default` (GET)

## 商家与商品接口
1. **商家查询**
   - 获取附近商家: `/stores/nearby` (GET) - 参数:经纬度、距离
   - 根据城市查询: `/stores/city` (GET)
   - 根据城市和区县查询: `/stores/cityAndDistrict` (GET)

2. **商品查询**
   - 获取商家商品: `/stores/{storeId}/products` (GET)
   - 分页获取商品: `/stores/{storeId}/products/page` (GET)

## 订单接口
1. **订单操作**
   - 计算订单价格: `/orders/price` (POST)
   - 创建订单: `/orders` (POST)
   - 根据ID查询订单: `/orders/{id}` (GET)
   - 根据订单号查询: `/orders/no/{orderNo}` (GET)
   - 查询用户的订单: `/orders/user/{userId}` (GET)
   - 支付订单: `/orders/{orderNo}/pay` (POST)
   - 取消订单: `/orders/{id}/cancel` (POST)

2. **优惠信息**
   - 获取可用优惠: `/promotions/applicable` (POST)

## 不适合前端直接调用的接口
1. **商家管理接口** (应由商家后台使用)
   - 创建商家: `/stores` (POST)
   - 更新商家信息: `/stores/{storeId}` (PUT)
   - 创建商品: `/products` (POST)
   - 更新商品: `/products/{productId}` (PUT)
   - 商家接单: `/orders/{id}/accept` (POST)
   - 商家拒单: `/orders/{id}/reject` (POST)
   - 完成订单: `/orders/{id}/complete` (POST)
   - 查询商家订单: `/orders/store/{storeId}` (GET)

2. **内部接口**
   - 内部令牌验证: `/internal/auth/token/verify` (GET)

## ApiService重构建议
根据项目现状，需要将模拟的`ApiService`替换为真实HTTP请求，可以按以下模块重构:

1. **AuthService**: 处理登录、注册、注销等认证逻辑
2. **UserService**: 用户信息、地址管理
3. **ShopService**: 商家查询、商品列表获取
4. **OrderService**: 订单创建、查询、状态管理 
5. **PromotionService**: 优惠相关

所有请求都应通过网关`localhost:8080`转发，并需要处理认证令牌的携带与刷新。