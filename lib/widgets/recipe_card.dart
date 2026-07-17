import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';

/// 菜谱卡片组件
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;
  final bool showQuickAdd;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onQuickAdd,
    this.showQuickAdd = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // 封面/Emoji
              _buildCover(context),
              SizedBox(width: AppConstants.paddingMedium),

              // 信息区域
              Expanded(
                child: _buildInfo(context),
              ),

              // 快速添加按钮
              if (showQuickAdd && onQuickAdd != null)
                _buildQuickAddButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建封面区域
  Widget _buildCover(BuildContext context) {
    final size = AppConstants.iconSizeXLarge + 16.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _parseColor(recipe.color),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: recipe.coverPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              child: Image.asset(
                recipe.coverPath!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildEmojiFallback();
                },
              ),
            )
          : _buildEmojiFallback(),
    );
  }

  /// 构建Emoji回退显示
  Widget _buildEmojiFallback() {
    return Center(
      child: Text(
        recipe.emoji,
        style: TextStyle(
          fontSize: AppConstants.fontSizeXLarge - 4,
        ),
      ),
    );
  }

  /// 构建信息区域
  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和收藏图标
        Row(
          children: [
            Expanded(
              child: Text(
                recipe.name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (recipe.favorite)
              Icon(
                Icons.favorite,
                color: AppConstants.errorColor,
                size: AppConstants.iconSizeSmall,
              ),
          ],
        ),

        SizedBox(height: AppConstants.paddingXSmall),

        // 描述
        Text(
          recipe.desc,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConstants.textSecondary,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: AppConstants.paddingSmall),

        // 查看做法提示
        Text(
          '查看做法 →',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  /// 构建快速添加按钮
  Widget _buildQuickAddButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      color: AppConstants.primaryColor,
      onPressed: onQuickAdd,
      tooltip: '加入菜单',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
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

/// 菜谱卡片网格版本（用于收藏页面）
class RecipeCardGrid extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCardGrid({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(AppConstants.paddingSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面区域
            _buildCover(context),

            // 信息区域
            Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: _buildInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final height = 120.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _parseColor(recipe.color),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusLarge),
          topRight: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      child: recipe.coverPath != null
          ? Image.asset(
              recipe.coverPath!,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildEmojiFallback();
              },
            )
          : _buildEmojiFallback(),
    );
  }

  Widget _buildEmojiFallback() {
    return Center(
      child: Text(
        recipe.emoji,
        style: TextStyle(
          fontSize: AppConstants.fontSizeXXLarge,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和收藏图标
        Row(
          children: [
            Expanded(
              child: Text(
                recipe.name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (recipe.favorite)
              Icon(
                Icons.favorite,
                color: AppConstants.errorColor,
                size: AppConstants.iconSizeSmall,
              ),
          ],
        ),

        SizedBox(height: AppConstants.paddingXSmall),

        // 描述
        Text(
          recipe.desc,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConstants.textSecondary,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppConstants.categoryColors.values.first;
    }
  }
}