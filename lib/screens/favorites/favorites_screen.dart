import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../utils/constants.dart';

/// 收藏页面
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // 确保在页面显示时刷新数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final favoriteRecipes = recipeProvider.favoriteRecipes;

          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteRecipes.isEmpty) {
            return _buildEmptyView();
          }

          return _buildRecipeGrid(favoriteRecipes);
        },
      ),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('我的收藏'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// 构建空视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: AppConstants.iconSizeXLarge,
            color: AppConstants.textSecondary,
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            '还没有收藏的菜谱',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            '去菜谱里看看吧',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建菜谱网格
  Widget _buildRecipeGrid(List<dynamic> recipes) {
    return GridView.builder(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCardGrid(
          recipe: recipe,
          onTap: () => _navigateToDetail(recipe.id),
        );
      },
    );
  }

  /// 导航到详情页面
  void _navigateToDetail(String recipeId) {
    Navigator.pushNamed(
      context,
      '/detail',
      arguments: {'recipeId': recipeId},
    );
  }
}