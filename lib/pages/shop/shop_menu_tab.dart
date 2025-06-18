import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food.dart';
import '../../models/shop.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';

class ShopMenuTab extends StatefulWidget {
  final Shop shop;
  const ShopMenuTab({super.key, required this.shop});

  @override
  State<ShopMenuTab> createState() => _ShopMenuTabState();
}

class _ShopMenuTabState extends State<ShopMenuTab> {
  // 添加滚动控制器
  final ScrollController _scrollController = ScrollController();
  // 当前选中的分类索引
  int _selectedCategoryIndex = 0;
  // 分类标题的位置信息
  final Map<String, double> _categoryPositions = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到指定分类
  void _scrollToCategory(String category) {
    if (_categoryPositions.containsKey(category)) {
      _scrollController.animateTo(
        _categoryPositions[category]!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 更新分类位置信息
  void _updateCategoryPosition(String category, double position) {
    _categoryPositions[category] = position;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        if (shopProvider.isLoadingMenu) {
          return const LoadingIndicator();
        }

        if (shopProvider.error != null) {
          return Center(
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
              ],
            ),
          );
        }

        final groupedMenu = shopProvider.menu;
        if (groupedMenu.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  '该商家暂未上架商品',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final categories = groupedMenu.keys.toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryList(context, categories),
            Expanded(
              child: _buildFoodList(context, groupedMenu),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList(BuildContext context, List<String> categories) {
    return Container(
      width: 90,
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategoryIndex == index;
          
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              _scrollToCategory(category);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[100],
                border: Border(
                  left: BorderSide(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.restaurant,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodList(BuildContext context, Map<String, List<Food>> groupedMenu) {
    final categories = groupedMenu.keys.toList();
    
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100), // 底部留白，避免被购物车挡住
      itemCount: groupedMenu.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final foods = groupedMenu[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用Builder获取分类标题的位置
            Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final position = box.localToGlobal(Offset.zero).dy;
                  // 减去AppBar和TabBar的高度，以获得相对于ListView的位置
                  final scrollPosition = position - 120; // 根据实际情况调整这个值
                  _updateCategoryPosition(category, scrollPosition);
                });
                
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  color: Colors.white,
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
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${foods.length}个菜品',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
            ...foods.map((food) => _buildFoodItem(context, food)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildFoodItem(BuildContext context, Food food) {
    final cartProvider = Provider.of<CartProvider>(context);
    final quantity = cartProvider.getQuantity(food);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 食品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              food.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 90,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 食品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name, 
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  food.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '月售 ${food.monthSales}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 价格和操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${food.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        if (quantity > 0)
                          InkWell(
                            onTap: () => cartProvider.decreaseFromCart(food),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        if (quantity > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        InkWell(
                          onTap: () => cartProvider.addToCart(food, widget.shop),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}