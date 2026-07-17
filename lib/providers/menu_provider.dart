import 'package:flutter/foundation.dart';
import '../models/menu.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

/// 菜单规划状态管理Provider
class MenuProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Map<String, Menu> _menus = {}; // 日期 -> 菜单
  CalendarMode _mode = CalendarMode.day;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, Menu> get menus => _menus;
  CalendarMode get mode => _mode;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 获取选中日期的菜单
  Menu? get selectedMenu => _menus[_formatDate(_selectedDate)];

  // 获取选中日期的菜谱ID列表
  List<String> get selectedRecipeIds => selectedMenu?.recipeIds ?? [];

  /// 初始化数据
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadMenus();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '加载菜单数据失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载所有菜单数据
  Future<void> _loadMenus() async {
    final menuList = await _dbService.getMenus();
    _menus = {
      for (var menu in menuList) menu.date: menu,
    };
    notifyListeners();
  }

  /// 切换日历视图模式
  void setMode(CalendarMode mode) {
    _mode = mode;
    notifyListeners();
  }

  /// 选择日期
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// 选择今天
  void selectToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  /// 上一页
  void previousPage() {
    switch (_mode) {
      case CalendarMode.day:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case CalendarMode.week:
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case CalendarMode.month:
        // 减去一个月
        final newDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
        _selectedDate = newDate;
        break;
    }
    notifyListeners();
  }

  /// 下一页
  void nextPage() {
    switch (_mode) {
      case CalendarMode.day:
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        break;
      case CalendarMode.week:
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        break;
      case CalendarMode.month:
        // 加上一个月
        final newDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        _selectedDate = newDate;
        break;
    }
    notifyListeners();
  }

  /// 添加菜谱到指定日期
  Future<void> addRecipeToDate(String recipeId, DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      final existingMenu = _menus[dateStr];

      Menu updatedMenu;
      if (existingMenu != null) {
        // 检查是否已存在
        if (existingMenu.recipeIds.contains(recipeId)) {
          _errorMessage = '所选日期已有这道菜';
          notifyListeners();
          return;
        }
        updatedMenu = existingMenu.addRecipe(recipeId);
      } else {
        updatedMenu = Menu(
          date: dateStr,
          recipeIds: [recipeId],
        );
      }

      await _dbService.insertMenu(updatedMenu);
      _menus[dateStr] = updatedMenu;

      notifyListeners();
    } catch (e) {
      _errorMessage = '添加菜谱失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 从指定日期移除菜谱
  Future<void> removeRecipeFromDate(String recipeId, DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      final existingMenu = _menus[dateStr];

      if (existingMenu != null) {
        final updatedMenu = existingMenu.removeRecipe(recipeId);

        if (updatedMenu.recipeIds.isEmpty) {
          // 如果没有菜谱了，删除该日期的菜单
          await _dbService.deleteMenu(dateStr);
          _menus.remove(dateStr);
        } else {
          await _dbService.updateMenu(updatedMenu);
          _menus[dateStr] = updatedMenu;
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '移除菜谱失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 清空指定日期的菜单
  Future<void> clearDate(DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      await _dbService.deleteMenu(dateStr);
      _menus.remove(dateStr);

      notifyListeners();
    } catch (e) {
      _errorMessage = '清空菜单失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 获取指定日期的菜谱列表
  List<String> getRecipesForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return _menus[dateStr]?.recipeIds ?? [];
  }

  /// 获取月视图数据
  List<CalendarDay> getMonthView() {
    final year = _selectedDate.year;
    final month = _selectedDate.month;

    // 获取当月第一天
    final firstDayOfMonth = DateTime(year, month, 1);
    // 获取当月最后一天
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // 获取第一天是星期几 (1-7, 1是周一)
    final firstWeekday = firstDayOfMonth.weekday;

    // 计算需要显示的上个月天数
    final prevMonthDays = firstWeekday - 1;

    // 生成42天的日历网格 (6周 x 7天)
    final List<CalendarDay> days = [];

    // 添加上个月的日期
    for (int i = prevMonthDays; i > 0; i--) {
      final date = DateTime(year, month, 1 - i);
      days.add(CalendarDay(
        date: date,
        isCurrentMonth: false,
        recipeIds: getRecipesForDate(date),
      ));
    }

    // 添加当月的日期
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(year, month, day);
      days.add(CalendarDay(
        date: date,
        isCurrentMonth: true,
        isSelected: _isSameDate(date, _selectedDate),
        recipeIds: getRecipesForDate(date),
      ));
    }

    // 添加下个月的日期，补齐到42天
    final remainingDays = 42 - days.length;
    for (int day = 1; day <= remainingDays; day++) {
      final date = DateTime(year, month + 1, day);
      days.add(CalendarDay(
        date: date,
        isCurrentMonth: false,
        recipeIds: getRecipesForDate(date),
      ));
    }

    return days;
  }

  /// 获取周视图数据
  List<CalendarDay> getWeekView() {
    // 获取本周一
    final today = _selectedDate;
    final weekday = today.weekday;
    final monday = today.subtract(Duration(days: weekday - 1));

    final List<CalendarDay> days = [];

    // 生成7天
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      days.add(CalendarDay(
        date: date,
        isCurrentMonth: date.month == _selectedDate.month,
        isSelected: _isSameDate(date, _selectedDate),
        recipeIds: getRecipesForDate(date),
      ));
    }

    return days;
  }

  /// 获取日视图数据
  CalendarDay getDayView() {
    return CalendarDay(
      date: _selectedDate,
      isCurrentMonth: true,
      isSelected: true,
      recipeIds: getRecipesForDate(_selectedDate),
    );
  }

  /// 获取未来14天的日期列表（用于快速添加）
  List<DateTime> getNext14Days() {
    final List<DateTime> days = [];
    final today = DateTime.now();

    for (int i = 0; i < 14; i++) {
      days.add(today.add(Duration(days: i)));
    }

    return days;
  }

  /// 检查指定日期是否有菜谱
  bool hasRecipesForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return _menus[dateStr]?.recipeIds.isNotEmpty ?? false;
  }

  /// 获取指定日期的菜谱数量
  int getRecipeCountForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return _menus[dateStr]?.recipeIds.length ?? 0;
  }

  /// 刷新数据
  Future<void> refresh() async {
    await initialize();
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// 比较两个日期是否相同
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 获取月份菜单统计
  Map<String, int> getMonthStatistics() {
    final Map<String, int> stats = {};

    for (var entry in _menus.entries) {
      final date = DateFormat('yyyy-MM').format(DateTime.parse(entry.key));
      stats[date] = (stats[date] ?? 0) + entry.value.recipeIds.length;
    }

    return stats;
  }
}

/// 日历视图模式
enum CalendarMode { day, week, month }

/// 日历天数据
class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final List<String> recipeIds;

  CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    this.isSelected = false,
    this.recipeIds = const [],
  });

  /// 获取星期几
  int get weekday => date.weekday;

  /// 获取日期数字
  int get day => date.day;

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 获取格式化的日期字符串
  String get dateString {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// 获取显示的日期字符串
  String get displayDate {
    return DateFormat(AppConstants.dateDisplayFormat).format(date);
  }

  /// 获取星期字符串
  String get weekdayString {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  /// 是否有菜谱
  bool get hasRecipes => recipeIds.isNotEmpty;

  /// 菜谱数量
  int get recipeCount => recipeIds.length;
}