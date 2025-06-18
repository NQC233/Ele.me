import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food.dart';
import '../../models/shop.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/loading_indicator.dart';

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
          return Center(child: Text('加载失败: ${shopProvider.error}'));
        }

        final groupedMenu = shopProvider.menu;
        if (groupedMenu.isEmpty) {
          return const Center(child: Text('该商家暂未上架商品'));
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
      width: 80,
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              _scrollToCategory(category);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: _selectedCategoryIndex == index ? Colors.white : Colors.grey[200],
                border: Border(
                  left: BorderSide(
                    color: _selectedCategoryIndex == index ? Theme.of(context).primaryColor : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: _selectedCategoryIndex == index ? FontWeight.bold : FontWeight.normal,
                  color: _selectedCategoryIndex == index ? Theme.of(context).primaryColor : Colors.black87,
                ),
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
                
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Image.network(
            food.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 80),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(food.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('月售 ${food.monthSales}'),
              ],
            ),
          ),
          Column(
            children: [
              Text('¥${food.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (quantity > 0)
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => cartProvider.decreaseFromCart(food),
                    ),
                  if (quantity > 0) Text('$quantity'),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () => cartProvider.addToCart(food, widget.shop),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}