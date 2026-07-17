import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

/// 菜单规划页面
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 视图切换
              _buildViewToggle(context, menuProvider),

              // 日历视图
              Expanded(
                child: _buildCalendarView(context, menuProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('菜单规划'),
    );
  }

  /// 构建视图切换按钮
  Widget _buildViewToggle(BuildContext context, MenuProvider menuProvider) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton(
              context,
              title: '日',
              isSelected: menuProvider.mode == CalendarMode.day,
              onTap: () => menuProvider.setMode(CalendarMode.day),
            ),
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: _buildViewButton(
              context,
              title: '周',
              isSelected: menuProvider.mode == CalendarMode.week,
              onTap: () => menuProvider.setMode(CalendarMode.week),
            ),
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: _buildViewButton(
              context,
              title: '月',
              isSelected: menuProvider.mode == CalendarMode.month,
              onTap: () => menuProvider.setMode(CalendarMode.month),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建视图按钮
  Widget _buildViewButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : AppConstants.outlineColor,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppConstants.onPrimary : AppConstants.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  /// 构建日历视图
  Widget _buildCalendarView(BuildContext context, MenuProvider menuProvider) {
    switch (menuProvider.mode) {
      case CalendarMode.day:
        return _buildDayView(context, menuProvider);
      case CalendarMode.week:
        return _buildWeekView(context, menuProvider);
      case CalendarMode.month:
        return _buildMonthView(context, menuProvider);
    }
  }

  /// 构建日视图
  Widget _buildDayView(BuildContext context, MenuProvider menuProvider) {
    final recipeIds = menuProvider.selectedRecipeIds;
    final recipeProvider = context.read<RecipeProvider>();

    return Column(
      children: [
        // 日期选择
        _buildDateSelector(context, menuProvider),

        // 菜谱列表
        Expanded(
          child: recipeIds.isEmpty
              ? _buildEmptyView(context)
              : _buildRecipeList(context, recipeIds, recipeProvider, menuProvider),
        ),
      ],
    );
  }

  /// 构建日期选择器
  Widget _buildDateSelector(BuildContext context, MenuProvider menuProvider) {
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
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => menuProvider.previousPage(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context, menuProvider),
              child: Column(
                children: [
                  Text(
                    DateFormat(AppConstants.dateDisplayFormat).format(menuProvider.selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    menuProvider.getDayView().weekdayString,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => menuProvider.nextPage(),
          ),
          TextButton(
            onPressed: () => menuProvider.selectToday(),
            child: const Text('今天'),
          ),
        ],
      ),
    );
  }

  /// 构建空视图
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: AppConstants.iconSizeXLarge,
            color: AppConstants.textSecondary,
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            '今天还没有安排菜谱',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            '去菜谱里挑选吧',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建菜谱列表
  Widget _buildRecipeList(
    BuildContext context,
    List<String> recipeIds,
    RecipeProvider recipeProvider,
    MenuProvider menuProvider,
  ) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return ListView.builder(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: recipeIds.length,
          itemBuilder: (context, index) {
            final recipeId = recipeIds[index];
            final recipe = recipeProvider.getRecipeById(recipeId);

            if (recipe == null) {
              return const SizedBox.shrink();
            }

            return _buildRecipeTile(
              context,
              recipe,
              recipeProvider,
              menuProvider,
            );
          },
        );
      },
    );
  }

  /// 构建菜谱项
  Widget _buildRecipeTile(
    BuildContext context,
    dynamic recipe,
    RecipeProvider recipeProvider,
    MenuProvider menuProvider,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _parseColor(recipe.color),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Center(
            child: Text(
              recipe.emoji,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(recipe.name),
        subtitle: Text(recipe.desc),
        trailing: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            // 只有群主才能删除
            if (!appProvider.isOwner) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.remove_circle),
              color: AppConstants.errorColor,
              onPressed: () async {
                final confirmed = await _showConfirmDialog(
                  context,
                  title: '移除菜谱',
                  content: '确定要从菜单中移除 ${recipe.name} 吗？',
                );

                if (confirmed == true) {
                  await menuProvider.removeRecipeFromDate(
                    recipe.id,
                    menuProvider.selectedDate,
                  );
                }
              },
            );
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: {'recipeId': recipe.id},
          );
        },
      ),
    );
  }

  /// 构建周视图
  Widget _buildWeekView(BuildContext context, MenuProvider menuProvider) {
    final days = menuProvider.getWeekView();
    final recipeProvider = context.read<RecipeProvider>();

    return Column(
      children: [
        // 周选择器
        _buildWeekSelector(context, menuProvider),

        // 周视图列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              return _buildWeekDayItem(context, day, recipeProvider, menuProvider);
            },
          ),
        ),
      ],
    );
  }

  /// 构建周选择器
  Widget _buildWeekSelector(BuildContext context, MenuProvider menuProvider) {
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
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => menuProvider.previousPage(),
          ),
          Expanded(
            child: Text(
              _getWeekRange(menuProvider.selectedDate),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => menuProvider.nextPage(),
          ),
          TextButton(
            onPressed: () => menuProvider.selectToday(),
            child: const Text('本周'),
          ),
        ],
      ),
    );
  }

  /// 获取周范围字符串
  String _getWeekRange(DateTime date) {
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    if (monday.month == sunday.month) {
      return '${monday.month}月${monday.day}日 - ${sunday.day}日';
    } else {
      return '${monday.month}月${monday.day}日 - ${sunday.month}月${sunday.day}日';
    }
  }

  /// 构建周日项
  Widget _buildWeekDayItem(
    BuildContext context,
    dynamic day,
    RecipeProvider recipeProvider,
    MenuProvider menuProvider,
  ) {
    final isToday = day.isToday;

    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期头部
            Row(
              children: [
                Text(
                  day.displayDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isToday ? AppConstants.primaryColor : AppConstants.textPrimary,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  day.weekdayString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
                if (isToday) ...[
                  SizedBox(width: AppConstants.paddingSmall),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryContainer,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      '今天',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ],
            ),

            // 菜谱列表
            if (day.hasRecipes) ...[
              SizedBox(height: AppConstants.paddingSmall),
              ...List.generate(day.recipeIds.length, (index) {
                final recipeId = day.recipeIds[index];
                final recipe = recipeProvider.getRecipeById(recipeId);

                if (recipe == null) {
                  return const SizedBox.shrink();
                }

                return _buildCompactRecipeTile(
                  context,
                  recipe,
                  day.date,
                  menuProvider,
                );
              }),
            ] else ...[
              SizedBox(height: AppConstants.paddingSmall),
              Text(
                '未安排',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建紧凑菜谱项
  Widget _buildCompactRecipeTile(
    BuildContext context,
    dynamic recipe,
    DateTime date,
    MenuProvider menuProvider,
  ) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.paddingXSmall),
          child: Row(
            children: [
              Text(
                recipe.emoji,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (appProvider.isOwner)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppConstants.errorColor,
                  iconSize: AppConstants.iconSizeSmall,
                  onPressed: () async {
                    final confirmed = await _showConfirmDialog(
                      context,
                      title: '移除菜谱',
                      content: '确定要从菜单中移除 ${recipe.name} 吗？',
                    );

                    if (confirmed == true) {
                      await menuProvider.removeRecipeFromDate(recipe.id, date);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// 构建月视图
  Widget _buildMonthView(BuildContext context, MenuProvider menuProvider) {
    final days = menuProvider.getMonthView();

    return Column(
      children: [
        // 月份选择器
        _buildMonthSelector(context, menuProvider),

        // 月日历网格
        Expanded(
          child: _buildMonthGrid(context, days, menuProvider),
        ),
      ],
    );
  }

  /// 构建月份选择器
  Widget _buildMonthSelector(BuildContext context, MenuProvider menuProvider) {
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
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => menuProvider.previousPage(),
          ),
          Expanded(
            child: Text(
              '${menuProvider.selectedDate.year}年${menuProvider.selectedDate.month}月',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => menuProvider.nextPage(),
          ),
          TextButton(
            onPressed: () => menuProvider.selectToday(),
            child: const Text('本月'),
          ),
        ],
      ),
    );
  }

  /// 构建月网格
  Widget _buildMonthGrid(BuildContext context, List<dynamic> days, MenuProvider menuProvider) {
    final recipeProvider = context.read<RecipeProvider>();

    return GridView.builder(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: days.length + 7, // +7 for weekday headers
      itemBuilder: (context, index) {
        if (index < 7) {
          // 星期标题
          final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
          return Center(
            child: Text(
              weekdays[index],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }

        final day = days[index - 7];
        return _buildMonthDayCell(context, day, recipeProvider);
      },
    );
  }

  /// 构建月日单元格
  Widget _buildMonthDayCell(
    BuildContext context,
    dynamic day,
    RecipeProvider recipeProvider,
  ) {
    return GestureDetector(
      onTap: () {
        menuProvider.selectDate(day.date);
        menuProvider.setMode(CalendarMode.day);
      },
      child: Container(
        decoration: BoxDecoration(
          color: day.isCurrentMonth
              ? (day.isSelected ? AppConstants.primaryContainer : AppConstants.cardColor)
              : AppConstants.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: day.isToday
              ? Border.all(color: AppConstants.primaryColor)
              : null,
        ),
        child: Stack(
          children: [
            // 日期数字
            Center(
              child: Text(
                '${day.day}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: day.isCurrentMonth
                          ? AppConstants.textPrimary
                          : AppConstants.textSecondary,
                      fontWeight: day.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),

            // 菜谱指示点
            if (day.hasRecipes)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: List.generate(
                    day.recipeCount > 3 ? 3 : day.recipeCount,
                    (i) => Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 显示日期选择器
  Future<void> _showDatePicker(BuildContext context, MenuProvider menuProvider) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: menuProvider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selected != null) {
      menuProvider.selectDate(selected);
    }
  }

  /// 显示确认对话框
  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
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