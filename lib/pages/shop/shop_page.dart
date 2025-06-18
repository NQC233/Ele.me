import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';

import 'package:elm/models/shop.dart';
import 'package:elm/providers/shop_provider.dart';
import 'package:elm/widgets/common/loading_indicator.dart';
import 'package:elm/pages/shop/shop_info_tab.dart';
import 'package:elm/pages/shop/shop_menu_tab.dart';
import 'package:elm/pages/shop/shop_reviews_tab.dart';
import 'package:elm/widgets/shop/cart_bar.dart';
import 'package:elm/config/app_theme.dart';

class ShopPage extends StatefulWidget {
  final String shopId;
  const ShopPage({super.key, required this.shopId});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 监听滚动以显示/隐藏标题
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('加载商店详情，shopId: ${widget.shopId}');
      Provider.of<ShopProvider>(context, listen: false).getShopDetails(widget.shopId);
    });
    
    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 140;
    if (showTitle != _showTitle) {
      setState(() {
        _showTitle = showTitle;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    
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
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            shop.logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('加载店铺图片失败: $error');
              return Container(color: Colors.grey.shade300);
            },
          ),
          // 添加渐变遮罩
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 有图片，构建轮播
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 220.0,
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
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.error)),
                        ),
                    ),
                    // 添加渐变遮罩
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  // 构建店铺信息头部
  Widget _buildShopHeader(Shop shop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 店铺Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  shop.logoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.store, color: Colors.grey),
                    ),
                ),
              ),
              const SizedBox(width: 12),
              // 店铺信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '⭐ ${shop.averageRating?.toStringAsFixed(1) ?? '暂无评分'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Text(' · '),
                        Text(
                          '月售${shop.monthSales ?? 0}单',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shop.estimatedDeliveryTime}分钟送达 | 距离${_formatDistance(shop.distance ?? 0)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (shop.notice != null && shop.notice!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shop.notice!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部AppBar
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    shop.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(shop),
                ),
              ),
              
              // 店铺信息头部
              SliverToBoxAdapter(
                child: _buildShopHeader(shop),
              ),
              
              // 标签栏
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: '点餐'),
                      Tab(text: '评价'),
                      Tab(text: '商家'),
                    ],
                  ),
                ),
                pinned: true,
              ),
              
              // 标签内容
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ShopMenuTab(shop: shop),
                    ShopReviewsTab(shop: shop),
                    ShopInfoTab(shop: shop),
                  ],
                ),
              ),
            ],
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
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}