import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/shop.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/shop/cart_bar.dart';
import 'shop_info_tab.dart';
import 'shop_menu_tab.dart';
import 'shop_reviews_tab.dart';
import '../../config/app_theme.dart';

///
/// 商家详情页 (已重构)
///
/// 这是一个包含多个选项卡的页面，用于展示单个商家的详细信息。
/// 主要包括 "点餐" 和 "商家" 两个部分。
///
class ShopPage extends StatefulWidget {
  final String shopId;
  const ShopPage({Key? key, required this.shopId}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 在第一帧后获取数据，避免initState中的context问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchShopById(widget.shopId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用 Consumer 来监听 ShopProvider 的变化
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isFetchingDetails || shopProvider.currentShop == null) {
            return const LoadingIndicator(text: '正在加载商家信息...');
          }

          final shop = shopProvider.currentShop!;
          return _buildShopDetails(context, shop);
        },
      ),
      bottomNavigationBar: const CartBar(),
    );
  }

  Widget _buildShopDetails(BuildContext context, Shop shop) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          _buildSliverAppBar(context, shop, innerBoxIsScrolled),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.textColor,
                unselectedLabelColor: AppTheme.secondaryTextColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: const <Widget>[
                  Tab(text: '点餐'),
                  Tab(text: '评价'),
                  Tab(text: '商家'),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ShopMenuTab(shop: shop),
          const ShopReviewsTab(),
          ShopInfoTab(shop: shop),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Shop shop, bool isScrolled) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      title: isScrolled ? Text(shop.name) : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: shop.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16 + 48,
              left: 16,
              right: 16,
              child: _buildShopHeaderInfo(shop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeaderInfo(Shop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('⭐ ${shop.rating}', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 8),
            Text('月售 ${shop.monthSales}+', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 8),
            Text('约 ${shop.deliveryTime} 分钟', style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '公告: ${shop.notice}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[200], fontSize: 12),
        ),
      ],
    );
  }
}

///
/// 用于固定TabBar的SliverPersistentHeaderDelegate
///
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // 设置背景色以避免滚动时内容穿透
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
} 