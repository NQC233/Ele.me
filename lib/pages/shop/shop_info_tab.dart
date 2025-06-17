import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shop.dart';
import '../../config/app_theme.dart';
import '../../providers/shop_provider.dart';

///
/// 商家详情页的"商家"选项卡
///
/// 用于展示商家的详细信息，如地址、营业时间等。
///
class ShopInfoTab extends StatelessWidget {
  final Shop shop;
  const ShopInfoTab({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 16),
          _buildBusinessHoursCard(context),
          const SizedBox(height: 16),
          _buildMenuCard(context),
        ],
      ),
    );
  }

  // 基本信息卡片
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '商家信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _infoRow(Icons.location_on, shop.address),
            const SizedBox(height: 8),
            _infoRow(Icons.phone, '暂无联系方式'),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time, _getBusinessHoursText()),
            const SizedBox(height: 8),
            _infoRow(Icons.announcement, shop.notice ?? '暂无公告'),
          ],
        ),
      ),
    );
  }

  // 获取营业时间文本
  String _getBusinessHoursText() {
    final hours = shop.getBusinessHoursList();
    if (hours.isEmpty) {
      return '暂无营业时间信息';
    }
    return hours.join(', ');
  }

  // 营业时间卡片
  Widget _buildBusinessHoursCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '营业时间',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...shop.getBusinessHoursList().map((time) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(time),
            )),
          ],
        ),
      ),
    );
  }

  // 菜单卡片
  Widget _buildMenuCard(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        final menu = shopProvider.menu;
        
        if (menu.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('暂无菜单信息')),
            ),
          );
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '菜单分类',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                ...menu.keys.map((category) => _buildCategoryItem(category, menu[category]!.length)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 菜单分类项
  Widget _buildCategoryItem(String category, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            '$count 项',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 信息行
  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryTextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
} 