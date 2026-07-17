import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/app_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/recipe_card.dart';
import '../utils/constants.dart';
import '../models/recipe.dart';
import 'package:intl/intl.dart';

/// 首页 - 菜谱浏览页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recipeProvider.errorMessage != null) {
            return _buildErrorView(recipeProvider.errorMessage!);
          }

          return Row(
            children: [
              // 左侧分类栏
              _buildCategorySidebar(recipeProvider),

              // 右侧菜谱列表
              Expanded(child: _buildRecipeList(recipeProvider)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final greeting = _getGreeting();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          );
        },
      ),
      actions: [
        // 收藏快捷入口
        IconButton(
          icon: const Icon(Icons.favorite_outline),
          onPressed: () {
            Navigator.pushNamed(context, '/favorites');
          },
          tooltip: '我的收藏',
        ),
      ],
    );
  }

  /// 获取问候语
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '夜深了';
    } else if (hour < 9) {
      return '早上好';
    } else if (hour < 12) {
      return '上午好';
    } else if (hour < 14) {
      return '中午好';
    } else if (hour < 18) {
      return '下午好';
    } else if (hour < 22) {
      return '晚上好';
    } else {
      return '夜深了';
    }
  }

  /// 构建错误视图
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppConstants.iconSizeXLarge,
            color: AppConstants.errorColor,
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton(
            onPressed: () {
              context.read<RecipeProvider>().refresh();
            },
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  /// 构建分类侧边栏
  Widget _buildCategorySidebar(RecipeProvider recipeProvider) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(
          right: BorderSide(color: AppConstants.outlineColor, width: 1),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
        itemCount: recipeProvider.categories.length,
        itemBuilder: (context, index) {
          final category = recipeProvider.categories[index];
          final isSelected = category.id == recipeProvider.selectedCategoryId;

          return _buildCategoryItem(category, isSelected, recipeProvider);
        },
      ),
    );
  }

  /// 构建分类项
  Widget _buildCategoryItem(
    dynamic category,
    bool isSelected,
    RecipeProvider recipeProvider,
  ) {
    return GestureDetector(
      onTap: () {
        recipeProvider.selectCategory(category.id);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingXSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryContainer
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppConstants.primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : AppConstants.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建菜谱列表
  Widget _buildRecipeList(RecipeProvider recipeProvider) {
    final recipes = recipeProvider.recipes;
    final hasSearch = recipeProvider.searchKeyword.isNotEmpty;

    if (recipes.isEmpty) {
      return _buildEmptyView(hasSearch);
    }

    return Column(
      children: [
        // 搜索栏
        _buildSearchBar(recipeProvider),

        // 菜谱数量
        _buildRecipeCount(recipes.length, recipeProvider),

        // 菜谱列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () => _navigateToDetail(recipe.id),
                onQuickAdd: () => _showQuickAddDialog(recipe),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(RecipeProvider recipeProvider) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索菜谱名称或食材...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: recipeProvider.searchKeyword.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    recipeProvider.clearSearch();
                  },
                )
              : null,
        ),
        onChanged: (value) {
          recipeProvider.setSearchKeyword(value);
        },
      ),
    );
  }

  /// 构建菜谱数量显示
  Widget _buildRecipeCount(int count, RecipeProvider recipeProvider) {
    String text;
    if (recipeProvider.searchKeyword.isNotEmpty) {
      text = '找到 $count 道菜谱';
    } else {
      final category = recipeProvider.selectedCategory;
      text = '${category?.name ?? '全部'} · $count 道菜谱';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Row(
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建空视图
  Widget _buildEmptyView(bool isSearchResult) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.restaurant_menu,
            size: AppConstants.iconSizeXLarge,
            color: AppConstants.textSecondary,
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            isSearchResult ? '没有找到相关菜谱' : '暂无菜谱',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (!isSearchResult) ...[
            SizedBox(height: AppConstants.paddingSmall),
            Text(
              '点击右下角 + 添加菜谱',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建浮动操作按钮
  Widget _buildFloatingActionButton() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            // 只有群主才能添加菜谱
            if (!appProvider.isOwner) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editor');
              },
              child: const Icon(Icons.add),
            );
          },
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

  /// 显示快速添加对话框
  void _showQuickAddDialog(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuickAddSheet(recipe: recipe),
    );
  }
}

/// 快速添加底部表单
class _QuickAddSheet extends StatefulWidget {
  final Recipe recipe;

  const _QuickAddSheet({required this.recipe});

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    // 默认选择今天
    _selectedDate = DateFormat(AppConstants.dateFormat).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildHeader(context),

          // 日历选择
          _buildCalendarSelector(context, menuProvider),

          // 确认按钮
          _buildConfirmButton(context, menuProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(
          bottom: BorderSide(color: AppConstants.outlineColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            '选择日期',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSelector(BuildContext context, MenuProvider menuProvider) {
    final dates = menuProvider.getNext14Days();

    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final dateStr = DateFormat(AppConstants.dateFormat).format(date);
          final isSelected = dateStr == _selectedDate;
          final isToday = DateFormat(AppConstants.dateFormat).format(DateTime.now()) == dateStr;

          final day = date.day;
          final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
          final weekday = weekdays[date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = dateStr;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryColor
                    : isToday
                        ? AppConstants.primaryContainer
                        : AppConstants.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : isToday
                          ? AppConstants.primaryColor
                          : AppConstants.outlineColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppConstants.onPrimary
                              : AppConstants.textSecondary,
                          fontSize: 10,
                        ),
                  ),
                  Text(
                    '$day',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppConstants.onPrimary
                              : AppConstants.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildConfirmButton(BuildContext context, MenuProvider menuProvider) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final date = DateTime.parse(_selectedDate);
            await menuProvider.addRecipeToDate(widget.recipe.id, date);

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已加入 $_selectedDate 菜单'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text('加入 $_selectedDate 菜单'),
        ),
      ),
    );
  }
}