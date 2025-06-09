import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/shop/shop_list_item.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';

///
/// 首页的"主页"选项卡内容
///
/// 这个Widget包含了原HomePage的主要UI，如地址栏、搜索、分类和商店列表。
///
class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // 页面加载时，自动获取商家列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
    });
  }

  // 模拟的食品分类数据
  final List<Map<String, String>> _categories = [
    {'icon': '🍔', 'name': '美食'},
    {'icon': '🥤', 'name': '饮品'},
    {'icon': '🛒', 'name': '超市'},
    {'icon': '🍎', 'name': '水果'},
    {'icon': '💊', 'name': '买药'},
    {'icon': '🍰', 'name': '甜点'},
    {'icon': '💐', 'name': '鲜花'},
    {'icon': '🍗', 'name': '炸鸡'},
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ShopProvider>(context, listen: false).fetchShops(sortBy: 'distance');
      },
      child: CustomScrollView(
        slivers: [
          // 顶部AppBar，包含地址和搜索
          _buildSliverAppBar(context),
          
          // 功能分类网格
          SliverToBoxAdapter(child: _buildCategoriesGrid()),
          
          // 推荐商家标题
          _buildSectionHeader(),
          
          // 商家列表
          _buildShopList(),
        ],
      ),
    );
  }

  // 构建SliverAppBar
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final address = userProvider.selectedAddress;
    final displayAddress = address != null ? address.fullAddress : '请选择收货地址';

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: AppTheme.primaryColor,
      title: GestureDetector(
        onTap: () { /* 跳转到地址选择页 */ },
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                displayAddress,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
            onTap: () { /* 跳转到搜索页 */ },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '搜索商家或商品',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建分类网格
  Widget _buildCategoriesGrid() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category['icon']!, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(category['name']!, style: const TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }

  // 构建区域标题
  Widget _buildSectionHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              '推荐商家',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建商家列表
  Widget _buildShopList() {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        if (shopProvider.isLoading && shopProvider.shops.isEmpty) {
          return const SliverFillRemaining(child: Center(child: LoadingIndicator()));
        }

        if (shopProvider.shops.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('附近没有商家')));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final shop = shopProvider.shops[index];
              return ShopListItem(
                shop: shop,
                onTap: () => context.push(AppRoutes.shop, extra: shop),
              );
            },
            childCount: shopProvider.shops.length,
          ),
        );
      },
    );
  }
} 