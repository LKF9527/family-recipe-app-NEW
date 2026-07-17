import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/app_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

/// 菜谱详情页面
class DetailScreen extends StatefulWidget {
  final String? recipeId;

  const DetailScreen({super.key, this.recipeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    if (widget.recipeId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final recipeProvider = context.read<RecipeProvider>();
    final recipe = recipeProvider.getRecipeById(widget.recipeId!);

    setState(() {
      _recipe = recipe;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipe == null) {
      return _buildNotFoundView();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 自定义应用栏
          _buildAppBar(context),

          // 内容区域
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建未找到视图
  Widget _buildNotFoundView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('菜谱详情'),
      ),
      body: Center(
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
              '菜谱不存在',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建应用栏
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _parseColor(_recipe!.color),
      flexibleSpace: FlexibleSpaceBar(
        background: _recipe!.coverPath != null
            ? Image.asset(
                _recipe!.coverPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildEmojiFallback();
                },
              )
            : _buildEmojiFallback(),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // 编辑按钮（仅群主）
        Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            if (!appProvider.isOwner) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/editor',
                  arguments: {'recipeId': _recipe!.id},
                );
              },
              tooltip: '编辑菜谱',
            );
          },
        ),
        // 收藏按钮
        Consumer<RecipeProvider>(
          builder: (context, recipeProvider, child) {
            return IconButton(
              icon: Icon(
                _recipe!.favorite ? Icons.favorite : Icons.favorite_border,
                color: _recipe!.favorite
                    ? AppConstants.errorColor
                    : AppConstants.onPrimary,
              ),
              onPressed: () async {
                await recipeProvider.toggleFavorite(_recipe!.id);
                await _loadRecipe(); // 重新加载数据
              },
              tooltip: _recipe!.favorite ? '取消收藏' : '收藏',
            );
          },
        ),
      ],
    );
  }

  /// 构建Emoji回退显示
  Widget _buildEmojiFallback() {
    return Container(
      color: _parseColor(_recipe!.color),
      child: Center(
        child: Text(
          _recipe!.emoji,
          style: TextStyle(
            fontSize: 80,
          ),
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXLarge),
          topRight: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和描述
            _buildHeader(),

            SizedBox(height: AppConstants.paddingLarge),

            // 食材
            _buildSection(context, '食材', _recipe!.ingredients),

            SizedBox(height: AppConstants.paddingLarge),

            // 调料
            _buildSection(context, '调料', _recipe!.seasonings),

            SizedBox(height: AppConstants.paddingLarge),

            // 步骤
            _buildSteps(context),
          ],
        ),
      ),
    );
  }

  /// 构建标题和描述
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _recipe!.name,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: AppConstants.paddingSmall),
        Text(
          _recipe!.desc,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppConstants.textSecondary,
              ),
        ),
      ],
    );
  }

  /// 构建食材/调料部分
  Widget _buildSection(
    BuildContext context,
    String title,
    List<dynamic> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: AppConstants.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppConstants.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.amount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建步骤部分
  Widget _buildSteps(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '步骤',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: AppConstants.paddingMedium),
        ...List.generate(_recipe!.steps.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 步骤编号
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),

                // 步骤内容
                Expanded(
                  child: Text(
                    _recipe!.steps[index],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(
          top: BorderSide(color: AppConstants.outlineColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final recipeProvider = context.read<RecipeProvider>();
                await recipeProvider.toggleFavorite(_recipe!.id);
                await _loadRecipe();
              },
              icon: Icon(_recipe!.favorite ? Icons.favorite : Icons.favorite_border),
              label: Text(_recipe!.favorite ? '已收藏' : '收藏'),
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddToMenuDialog(context),
              icon: const Icon(Icons.calendar_today),
              label: const Text('加入菜单'),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示添加到菜单对话框
  void _showAddToMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddToMenuSheet(recipe: _recipe!),
    );
  }

  /// 解析颜色
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppConstants.categoryColors.values.first;
    }
  }
}

/// 添加到菜单底部表单
class _AddToMenuSheet extends StatefulWidget {
  final Recipe recipe;

  const _AddToMenuSheet({required this.recipe});

  @override
  State<_AddToMenuSheet> createState() => _AddToMenuSheetState();
}

class _AddToMenuSheetState extends State<_AddToMenuSheet> {
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat(AppConstants.dateFormat).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
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
          _buildCalendarSelector(context),

          // 确认按钮
          _buildConfirmButton(context),
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

  Widget _buildCalendarSelector(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
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

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final menuProvider = context.read<MenuProvider>();
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