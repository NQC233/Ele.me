import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/shop.dart';
import '../../config/app_theme.dart';

///
/// 商家列表项组件 (已重构)
///
/// 根据饿了么的UI风格，全面优化了商家信息的展示布局。
///
class ShopListItem extends StatelessWidget {
  final Shop shop;
  final VoidCallback? onTap;

  const ShopListItem({
    Key? key,
    required this.shop,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：商家图片
            _buildShopImage(),
            const SizedBox(width: 12),
            // 右侧：商家信息
            Expanded(child: _buildShopInfo()),
          ],
        ),
      ),
    );
  }

  // 构建商家图片（带"品牌"标签）
  Widget _buildShopImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: shop.image,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              '品牌',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // 构建右侧的商家信息区域
  Widget _buildShopInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第一行：店名和"..."
        _buildTitleRow(),
        const SizedBox(height: 6),
        // 第二行：评分、销量、配送信息
        _buildStatsRow(),
        const SizedBox(height: 6),
        // 第三行：起送价和配送费
        _buildFeeRow(),
        const SizedBox(height: 8),
        // 分割线
        const Divider(height: 1, thickness: 0.5),
        const SizedBox(height: 8),
        // 第四行：榜单和活动
        _buildActivityRow(),
      ],
    );
  }

  // 店名行
  Widget _buildTitleRow() {
    return Text(
      shop.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  // 核心数据行（评分、销量等）
  Widget _buildStatsRow() {
    return DefaultTextStyle(
      style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12, fontFamily: 'Roboto'),
      child: Row(
        children: [
          Text('⭐${shop.rating.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFFED6A00), fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('月售${shop.monthSales}+'),
          const SizedBox(width: 8),
          Text('${shop.deliveryTime}分钟'),
          const SizedBox(width: 8),
          Text('${shop.distance.toStringAsFixed(1)}km'),
        ],
      ),
    );
  }

  // 配送费用行
  Widget _buildFeeRow() {
    return DefaultTextStyle(
      style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12, fontFamily: 'Roboto'),
      child: Row(
        children: [
          Text('起送 ¥${shop.minOrderAmount.toStringAsFixed(0)}'),
          const SizedBox(width: 8),
          const Text('|'),
          const SizedBox(width: 8),
          Text('配送 ¥${shop.deliveryFee.toStringAsFixed(1)}'),
          if (shop.originalDeliveryFee != null && shop.originalDeliveryFee! > shop.deliveryFee)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                '¥${shop.originalDeliveryFee!.toStringAsFixed(1)}',
                style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppTheme.hintTextColor),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text('蜂鸟准时达', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ],
      ),
    );
  }
  
  // 活动和榜单行
  Widget _buildActivityRow() {
    final List<Widget> children = [];
    
    // 添加榜单信息
    if (shop.ranking != null) {
      children.add(_buildRankingTag(shop.ranking!));
    }

    // 添加活动信息
    for (var activity in shop.activities) {
      children.add(_buildActivityTag(activity));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: children,
    );
  }

  // 构建榜单标签
  Widget _buildRankingTag(String rankingText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E8),
        border: Border.all(color: const Color(0xFFED6A00)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        '榜 $rankingText',
        style: const TextStyle(fontSize: 10, color: Color(0xFFED6A00), fontWeight: FontWeight.bold),
      ),
    );
  }
  
  // 构建活动标签
  Widget _buildActivityTag(String activityText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        activityText,
        style: TextStyle(fontSize: 10, color: Colors.red.shade700),
      ),
    );
  }
} 