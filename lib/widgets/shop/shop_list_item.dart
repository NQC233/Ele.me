import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/shop.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

///
/// 商店列表项
///
/// 在首页和搜索页面展示的单个商店卡片。
///
class ShopListItem extends StatelessWidget {
  final Shop shop;

  const ShopListItem({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 使用路径参数方式导航到商店页面
        AppRoutes.router.push('${AppRoutes.shop}/${shop.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopLogo(),
            const SizedBox(width: 12),
            Expanded(child: _buildShopInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildShopLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: CachedNetworkImage(
        imageUrl: shop.logoUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildShopInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('⭐ ${shop.averageRating?.toStringAsFixed(1) ?? '暂无评分'}'),
            const Text(' · '),
            Text('月售${shop.monthSales ?? 0}单'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '起送¥${shop.minimumOrderAmount}',
              style: const TextStyle(color: AppTheme.secondaryTextColor),
            ),
            const Text(' · '),
            Text(
              '配送¥${shop.deliveryFee}',
              style: const TextStyle(color: AppTheme.secondaryTextColor),
            ),
            const Text(' · '),
            Text(
              '${shop.estimatedDeliveryTime}分钟',
              style: const TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ],
        ),
        if (shop.distance != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '距离${_formatDistance(shop.distance!)}',
              style: const TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ),
      ],
    );
  }

  String _formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters米';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)}公里';
    }
  }
} 