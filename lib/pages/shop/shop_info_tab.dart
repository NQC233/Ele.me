import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../config/app_theme.dart';

///
/// 商家详情页的"商家"选项卡
///
/// 用于展示商家的详细信息，如地址、营业时间等。
///
class ShopInfoTab extends StatelessWidget {
  final Shop shop;
  const ShopInfoTab({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('商家信息'),
        const SizedBox(height: 8),
        _buildInfoCard([
          _buildInfoRow(Icons.location_on_outlined, '地址', shop.address),
          _buildInfoRow(Icons.access_time_outlined, '营业时间', shop.businessHours.join(' ')),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle('配送服务'),
        const SizedBox(height: 8),
        _buildInfoCard([
          _buildInfoRow(Icons.delivery_dining_outlined, '配送服务', '由蜂鸟快送提供，约${shop.deliveryTime}分钟送达'),
          _buildInfoRow(Icons.monetization_on_outlined, '配送费', '¥${shop.deliveryFee}'),
        ]),
        const SizedBox(height: 24),
        // 可以在这里添加更多信息，如商家资质等
      ],
    );
  }

  // 构建区域标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // 构建信息卡片
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // 构建单行信息
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.secondaryTextColor, size: 20),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
} 