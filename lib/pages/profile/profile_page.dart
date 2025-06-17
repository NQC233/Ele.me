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
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          return Center(
            child: ElevatedButton(
              onPressed: () => AppRoutes.router.push(AppRoutes.login),
              child: const Text('登录/注册'),
            ),
          );
        }

        final user = userProvider.user!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('我的'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => userProvider.logout(),
              )
            ],
          ),
          body: ListView(
            children: <Widget>[
              _buildHeader(context, user),
              const SizedBox(height: 20),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: '我的地址',
                onTap: () => AppRoutes.router.push(AppRoutes.addressList),
              ),
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: '我的订单',
                onTap: () => AppRoutes.router.push(AppRoutes.orders),
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: '帮助中心',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: '设置',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                user.phone ?? user.email ?? '未设置联系方式',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 