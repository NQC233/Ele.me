import 'package:flutter/material.dart';

///
/// 商家详情页的"评价"选项卡 (占位符)
///
class ShopReviewsTab extends StatelessWidget {
  const ShopReviewsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: 后续实现真实的评价列表
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '评价功能正在开发中...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
} 