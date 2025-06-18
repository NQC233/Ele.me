import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../config/app_theme.dart';

///
/// 商家详情页的"评价"选项卡 (占位符)
///
class ShopReviewsTab extends StatelessWidget {
  final Shop shop;
  const ShopReviewsTab({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    // TODO: 后续实现真实的评价列表
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewSummary(context),
          const SizedBox(height: 24),
          _buildEmptyReviews(context),
          const SizedBox(height: 80), // 底部留白，避免被购物车挡住
        ],
      ),
    );
  }
  
  // 评价摘要
  Widget _buildReviewSummary(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '评价摘要',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          shop.averageRating?.toStringAsFixed(1) ?? '暂无',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '/ 5分',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStar(1),
                        _buildStar(2),
                        _buildStar(3),
                        _buildStar(4),
                        _buildStar(5),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingBar('口味', 0.9),
                      const SizedBox(height: 8),
                      _buildRatingBar('包装', 0.8),
                      const SizedBox(height: 8),
                      _buildRatingBar('配送', 0.85),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建星星图标
  Widget _buildStar(int position) {
    final rating = shop.averageRating ?? 0;
    Color color;
    
    if (rating >= position) {
      color = Colors.amber;
    } else if (rating > position - 1) {
      color = Colors.amber.withOpacity(0.5);
    } else {
      color = Colors.grey.withOpacity(0.3);
    }
    
    return Icon(Icons.star, color: color, size: 16);
  }
  
  // 构建评分条
  Widget _buildRatingBar(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 5).toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  // 空评价状态
  Widget _buildEmptyReviews(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无评价',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '成为第一个评价该商家的用户吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现评价功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('评价功能正在开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('写评价'),
          ),
        ],
      ),
    );
  }
} 