import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../config/app_theme.dart';

///
/// 个人中心页面 (已美化)
///
/// 这是"我的"选项卡对应的页面。显示用户个人信息和设置选项。
/// 未登录时显示登录提示，但不自动跳转到登录页。
///
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final bool isLoggedIn = userProvider.isLoggedIn;
        final user = userProvider.user;

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 自定义AppBar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                  ),
                ),
                title: const Text('个人中心'),
                actions: [
                  if (isLoggedIn)
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        // TODO: 设置页面
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('设置功能暂未实现')),
                        );
                      },
                    ),
                ],
              ),
              
              // 个人信息卡片
              SliverToBoxAdapter(
                child: _buildUserCard(context, isLoggedIn, user),
              ),
              
              // 功能菜单
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 我的订单区域
                      _buildSectionTitle(context, '我的订单'),
                      const SizedBox(height: 8),
                      _buildOrderRow(context, isLoggedIn),
                      
                      const SizedBox(height: 24),
                      
                      // 我的服务区域
                      _buildSectionTitle(context, '我的服务'),
                      const SizedBox(height: 8),
                      _buildServiceGrid(context, isLoggedIn),
                    ],
                  ),
                ),
              ),
              
              // 退出登录按钮
              if (isLoggedIn)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => userProvider.logout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('退出登录'),
                    ),
                  ),
                ),
              
              // 底部版权信息
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'App Version 1.0.0',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 用户信息卡片
  Widget _buildUserCard(BuildContext context, bool isLoggedIn, user) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          GestureDetector(
            onTap: () {
              if (!isLoggedIn) {
                context.push(AppRoutes.login);
              }
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLoggedIn ? null : Colors.grey.shade200,
                image: isLoggedIn && user.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoggedIn && user.avatarUrl != null
                  ? null
                  : Icon(
                      Icons.person,
                      size: 36,
                      color: isLoggedIn ? Colors.white : theme.colorScheme.primary,
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名或登录提示
                GestureDetector(
                  onTap: () {
                    if (!isLoggedIn) {
                      context.push(AppRoutes.login);
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        isLoggedIn ? user.username : '点击登录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLoggedIn ? Colors.black87 : theme.colorScheme.primary,
                        ),
                      ),
                      if (!isLoggedIn) 
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 手机号或邮箱
                if (isLoggedIn)
                  Text(
                    user.phone ?? user.email ?? '未设置联系方式',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  
                if (!isLoggedIn)
                  Text(
                    '登录后享受更多功能',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          
          // 会员信息或登录按钮
          isLoggedIn
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '会员',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () => context.push(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('登录/注册'),
                ),
        ],
      ),
    );
  }

  // 分区标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 订单状态栏
  Widget _buildOrderRow(BuildContext context, bool isLoggedIn) {
    final List<Map<String, dynamic>> orderItems = [
      {'icon': Icons.payment, 'title': '待付款'},
      {'icon': Icons.shopping_bag, 'title': '待发货'},
      {'icon': Icons.local_shipping, 'title': '待收货'},
      {'icon': Icons.rate_review, 'title': '待评价'},
      {'icon': Icons.assignment, 'title': '全部订单'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: orderItems.map((item) {
          return GestureDetector(
            onTap: () {
              if (isLoggedIn) {
                context.push(AppRoutes.orders);
              } else {
                context.push(AppRoutes.login);
              }
            },
            child: Column(
              children: [
                Icon(
                  item['icon'],
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 服务网格
  Widget _buildServiceGrid(BuildContext context, bool isLoggedIn) {
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.location_on_outlined, 'title': '我的地址', 'route': AppRoutes.addressList},
      {'icon': Icons.card_giftcard_outlined, 'title': '优惠券', 'route': AppRoutes.coupons},
      {'icon': Icons.favorite_outline, 'title': '我的收藏', 'route': ''},
      {'icon': Icons.headset_mic_outlined, 'title': '客服中心', 'route': ''},
      {'icon': Icons.help_outline, 'title': '帮助中心', 'route': ''},
      {'icon': Icons.privacy_tip_outlined, 'title': '隐私政策', 'route': ''},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              if (isLoggedIn || service['title'] == '帮助中心' || service['title'] == '隐私政策') {
                if (service['route'].isNotEmpty) {
                  context.push(service['route']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${service['title']}功能暂未实现')),
                  );
                }
              } else {
                context.push(AppRoutes.login);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  service['icon'],
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  service['title'],
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 