import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../config/app_theme.dart';

///
/// 个人中心页面 (已重构)
///
/// 这是"我的"选项卡对应的页面。目前它只是一个简单的占位符，
/// 后续会在这里开发用户个人信息、设置等功能。
///
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return ListView(
            children: [
              // 用户信息头部
              userProvider.isLoggedIn
                  ? _buildUserProfileHeader(context, userProvider)
                  : _buildLoginHeader(context),
              
              const SizedBox(height: 10),

              // 功能列表
              _buildFeatureList(context),

              // 退出登录按钮
              if (userProvider.isLoggedIn) ...[
                const SizedBox(height: 20),
                _buildLogoutButton(context, userProvider),
                const SizedBox(height: 20),
              ]
            ],
          );
        },
      ),
    );
  }

  // 未登录时显示的头部
  Widget _buildLoginHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.router.go(AppRoutes.login),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: AppTheme.primaryColor,
        child: const Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
            ),
            SizedBox(width: 15),
            Text('登录 / 注册', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 登录后显示的用户信息头部
  Widget _buildUserProfileHeader(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user!;
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primaryColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
            child: user.avatar == null 
                ? const Icon(Icons.person, size: 40, color: AppTheme.primaryColor)
                : null,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(user.phone, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // 功能列表
  Widget _buildFeatureList(BuildContext context) {
    return Column(
      children: [
        _buildListTile(context, Icons.receipt_long_outlined, '我的订单', () => AppRoutes.router.go(AppRoutes.orders)),
        _buildListTile(context, Icons.location_on_outlined, '我的地址', () => AppRoutes.router.push(AppRoutes.addressList)),
        _buildListTile(context, Icons.card_giftcard_outlined, '优惠券', () { /* TODO */ }),
        const Divider(),
        _buildListTile(context, Icons.support_agent_outlined, '客服中心', () { /* TODO */ }),
        _buildListTile(context, Icons.settings_outlined, '设置', () { /* TODO */ }),
      ],
    );
  }

  // 创建单个列表项的辅助方法
  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryTextColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 退出登录按钮
  Widget _buildLogoutButton(BuildContext context, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlinedButton(
        onPressed: () {
          userProvider.logout();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('退出登录'),
      ),
    );
  }
} 