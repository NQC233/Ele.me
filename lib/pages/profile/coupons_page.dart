import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/promotion.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';

/// 优惠券页面
/// 
/// 展示用户拥有的所有优惠券
class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 使用Future.microtask来避免在build过程中调用setState
    Future.microtask(() => _loadCoupons());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    if (!mounted) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      setState(() {
        _errorMessage = "请先登录";
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await orderProvider.getUserCoupons(userProvider.user!.id);
      if (!mounted) return;
      if (orderProvider.userCoupons.isEmpty) {
        setState(() {
          _errorMessage = "暂无优惠券";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "加载优惠券失败: $e";
      });
      debugPrint('加载优惠券失败: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的优惠券'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '可用'),
            Tab(text: '已使用'),
            Tab(text: '已过期'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadCoupons,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator(size: 24))
          : _errorMessage != null 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyPlaceholder(
                        icon: Icons.error_outline,
                        title: '出错了',
                        subtitle: _errorMessage!,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadCoupons,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    final coupons = orderProvider.userCoupons;
                    
                    if (coupons.isEmpty) {
                      return const EmptyPlaceholder(
                        icon: Icons.card_giftcard_outlined,
                        title: '暂无优惠券',
                        subtitle: '没有找到任何优惠券',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadCoupons,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCouponList(coupons.where((c) => c.isUsable).toList()),
                          _buildCouponList(coupons.where((c) => c.isUsed).toList()),
                          _buildCouponList(coupons.where((c) => c.isExpired).toList()),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildCouponList(List<UserCoupon> coupons) {
    if (coupons.isEmpty) {
      return const EmptyPlaceholder(
        icon: Icons.card_giftcard_outlined,
        title: '暂无优惠券',
        subtitle: '该分类下没有优惠券',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) => _buildCouponCard(coupons[index]),
    );
  }

  Widget _buildCouponCard(UserCoupon coupon) {
    final DateTime validUntil = DateTime.tryParse(coupon.validUntil) ?? DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(validUntil);
    
    final Color cardColor = coupon.isUsable 
        ? AppTheme.primaryColor.withOpacity(0.8)
        : Colors.grey;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [cardColor, cardColor.withOpacity(0.7)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧金额
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '¥${coupon.discountAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '满${coupon.threshold}元可用',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 右侧详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          coupon.storeName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    coupon.ruleTypeDesc,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '有效期至: $formattedDate',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 