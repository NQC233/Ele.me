import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;

import '../../models/food.dart';
import '../../models/shop.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../config/app_theme.dart';

///
/// 商店详情页的"点餐"选项卡
///
class ShopMenuTab extends StatefulWidget {
  final Shop shop;
  const ShopMenuTab({Key? key, required this.shop}) : super(key: key);

  @override
  State<ShopMenuTab> createState() => _ShopMenuTabState();
}

class _ShopMenuTabState extends State<ShopMenuTab> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchFoods(widget.shop.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        if (shopProvider.isFetchingFoods) {
          return const LoadingIndicator(text: '正在加载菜单...');
        }
        if (shopProvider.foods.isEmpty) {
          return const Center(child: Text('暂无菜单信息'));
        }
        return _buildMenu(context, shopProvider.foods);
      },
    );
  }

  Widget _buildMenu(BuildContext context, List<Food> foods) {
    final categories = foods.map((e) => e.category).toSet().toList();
    // 默认选中第一个分类
    _selectedCategory ??= categories.first;

    final filteredFoods = foods.where((f) => f.category == _selectedCategory).toList();

    return Row(
      children: [
        // 左侧分类列表
        _buildCategoryList(categories),
        // 右侧菜品列表
        _buildFoodList(filteredFoods),
      ],
    );
  }

  // 构建分类列表
  Widget _buildCategoryList(List<String> categories) {
    return Container(
      width: 100,
      color: Colors.grey[100],
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              color: isSelected ? Colors.white : Colors.transparent,
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建菜品列表
  Widget _buildFoodList(List<Food> foods) {
    return Expanded(
      child: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              final quantity = cart.getQuantity(food.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: food.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.fastfood),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(food.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
                            const SizedBox(height: 8),
                            Text('¥${food.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      // 添加/移除购物车按钮
                      _buildAddToCartButton(context, food, quantity)
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 构建加购按钮
  Widget _buildAddToCartButton(BuildContext context, Food food, int quantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quantity > 0) ...[
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 28),
            onPressed: () {
              cartProvider.decreaseFromCart(food.id);
            },
          ),
          Text('$quantity', style: const TextStyle(fontSize: 16)),
        ],
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 28),
          onPressed: () {
            cartProvider.addToCart(widget.shop, food);
          },
        ),
      ],
    );
  }
} 