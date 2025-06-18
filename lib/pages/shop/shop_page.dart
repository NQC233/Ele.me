import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:elm/models/shop.dart';
import 'package:elm/providers/shop_provider.dart';
import 'package:elm/widgets/common/loading_indicator.dart';
import 'package:elm/pages/shop/shop_info_tab.dart';
import 'package:elm/pages/shop/shop_menu_tab.dart';
import 'package:elm/pages/shop/shop_reviews_tab.dart';
import 'package:elm/widgets/shop/cart_bar.dart';

class ShopPage extends StatefulWidget {
  final String shopId;
  const ShopPage({super.key, required this.shopId});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('加载商店详情，shopId: ${widget.shopId}');
      Provider.of<ShopProvider>(context, listen: false).getShopDetails(widget.shopId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 清理商店数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ShopProvider>(context, listen: false).clearCurrentShop();
      }
    });
    super.dispose();
  }

  // 构建图片轮播
  Widget _buildImageCarousel(Shop shop) {
    // 检查是否有图片
    final images = shop.images;
    if (images == null || images.isEmpty) {
      // 如果没有图片，显示店铺Logo
      return Image.network(
        shop.logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('加载店铺图片失败: $error');
          return Container(color: Colors.grey);
        },
      );
    }

    // 有图片，构建轮播
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error)),
                      ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        // 指示器
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      _currentCarouselIndex == entry.key ? 0.9 : 0.4,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        final shop = shopProvider.currentShop;

        if (shopProvider.isLoadingMenu && shop == null) {
          return const Scaffold(body: LoadingIndicator());
        }
        
        if (shopProvider.error != null) {
          debugPrint('加载商店详情时出错: ${shopProvider.error}');
          return Scaffold(
            appBar: AppBar(title: const Text('商店详情')),
            body: Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('加载失败: ${shopProvider.error}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('返回'),
                ),
              ],
            )),
          );
        }

        if (shop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('商店详情')),
            body: Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('无法加载商店信息'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('返回'),
                ),
              ],
            )),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(shop.name, style: const TextStyle(color: Colors.white, fontSize: 16.0)),
                    background: _buildImageCarousel(shop),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
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
              children: [
                ShopMenuTab(shop: shop),
                ShopReviewsTab(shop: shop),
                ShopInfoTab(shop: shop),
              ],
            ),
          ),
          bottomNavigationBar: CartBar(shop: shop),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}