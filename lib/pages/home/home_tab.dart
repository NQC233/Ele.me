import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../widgets/shop/shop_list_item.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';

///
/// 首页的"主页"选项卡内容 (已美化)
///
/// 这个Widget包含了原HomePage的主要UI，如地址栏、搜索、分类和商店列表。
///
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchShops();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchShops() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final address = userProvider.defaultAddress;

      if (address != null) {
        if (address.latitude != null && address.longitude != null) {
          await shopProvider.getNearbyShops(
            latitude: address.latitude!,
            longitude: address.longitude!,
          );
        } else {
          await shopProvider.getShopsByCity(city: address.city);
        }
      } else {
        await shopProvider.getShopsByCity(city: '昆明市');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 模拟的食品分类数据
  final List<Map<String, dynamic>> _categories = [
    {'icon': '🍔', 'name': '美食', 'color': const Color(0xFFFFC107)},
    {'icon': '🥤', 'name': '饮品', 'color': const Color(0xFF03A9F4)},
    {'icon': '🛒', 'name': '超市', 'color': const Color(0xFF4CAF50)},
    {'icon': '🍎', 'name': '水果', 'color': const Color(0xFFE91E63)},
    {'icon': '💊', 'name': '买药', 'color': const Color(0xFF9C27B0)},
    {'icon': '🍰', 'name': '甜点', 'color': const Color(0xFFFF5722)},
    {'icon': '💐', 'name': '鲜花', 'color': const Color(0xFF3F51B5)},
    {'icon': '🍗', 'name': '炸鸡', 'color': const Color(0xFF795548)},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _fetchShops,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 顶部AppBar，包含地址和搜索
            _buildSliverAppBar(context),
            
            // 食品分类滚动区域
            SliverToBoxAdapter(
              child: AnimationLimiter(
                child: _buildCategoriesSlider(theme),
              ),
            ),
            
            // 当前促销活动横幅
            SliverToBoxAdapter(
              child: _buildPromotionBanner(theme),
            ),
            
            // 推荐商家标题
            _buildSectionHeader(theme),
            
            // 商家列表
            _isLoading
                ? const SliverFillRemaining(child: LoadingIndicator())
                : _buildShopList(),
          ],
        ),
      ),
    );
  }

  // 构建SliverAppBar
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final address = userProvider.defaultAddress;
    final displayAddress = address != null ? address.fullAddress : '请选择收货地址';
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 160,
      backgroundColor: Color(0xFF2196F3).withOpacity(0.85),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2196F3),
                Color(0xFF42A5F5).withOpacity(0.9),
              ],
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        expandedTitleScale: 1.0,
        title: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.addressList),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _animationController.value) * 20,
                  ),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: child,
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      displayAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                (1 - _animationController.value) * 30,
              ),
              child: Opacity(
                opacity: _animationController.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.search),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '搜索商家或商品',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '搜索',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建分类滑动区域
  Widget _buildCategoriesSlider(ThemeData theme) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildCategoryItem(
                  _categories[index],
                  theme,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建单个分类项
  Widget _buildCategoryItem(Map<String, dynamic> category, ThemeData theme) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: category['color'].withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                category['icon'],
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category['name'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  // 构建促销横幅
  Widget _buildPromotionBanner(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.secondaryContainer,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -40,
                top: -40,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '新用户专享',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '首单立减20元',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '立即领取 >',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '🍜',
                          style: TextStyle(
                            fontSize: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建区域标题
  Widget _buildSectionHeader(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
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
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              child: Row(
                children: [
                  Text(
                    '查看全部',
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.primary,
                    size: 12,
                  ),
                ],
              ),
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
        if (shopProvider.error != null) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败: ${shopProvider.error}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchShops,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }

        if (shopProvider.shops.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '附近没有商家',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverAnimatedList(
            initialItemCount: shopProvider.shops.length,
            itemBuilder: (context, index, animation) {
              final shop = shopProvider.shops[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ShopListItem(shop: shop),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 