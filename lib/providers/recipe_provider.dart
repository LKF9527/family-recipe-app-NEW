import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/category.dart';
import '../services/database_service.dart';

/// 菜谱状态管理Provider
class RecipeProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Recipe> _recipes = [];
  List<Category> _categories = [];
  List<Recipe> _filteredRecipes = [];
  String _selectedCategoryId = '';
  String _searchKeyword = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Recipe> get recipes => _filteredRecipes;
  List<Recipe> get allRecipes => _recipes;
  List<Category> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchKeyword => _searchKeyword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get recipeCount => _recipes.length;

  // 获取选中的分类
  Category? get selectedCategory {
    try {
      return _categories.firstWhere((cat) => cat.id == _selectedCategoryId);
    } catch (e) {
      return null;
    }
  }

  // 获取收藏的菜谱
  List<Recipe> get favoriteRecipes {
    return _recipes.where((recipe) => recipe.favorite).toList();
  }

  // 根据分类获取菜谱数量
  int getRecipeCountByCategory(String categoryId) {
    return _recipes.where((recipe) => recipe.categoryId == categoryId).length;
  }

  /// 初始化数据
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadCategories();
      await _loadRecipes();

      // 默认选择第一个分类
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '加载菜谱数据失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载分类数据
  Future<void> _loadCategories() async {
    _categories = await _dbService.getCategories();
    notifyListeners();
  }

  /// 加载菜谱数据
  Future<void> _loadRecipes() async {
    _recipes = await _dbService.getRecipes();
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await initialize();
  }

  /// 选择分类
  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  /// 设置搜索关键词
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    _applyFilters();
    notifyListeners();
  }

  /// 清除搜索
  void clearSearch() {
    _searchKeyword = '';
    _applyFilters();
    notifyListeners();
  }

  /// 应用过滤条件
  void _applyFilters() {
    _filteredRecipes = _recipes.where((recipe) {
      // 分类过滤
      bool categoryMatch = _searchKeyword.isEmpty || recipe.categoryId == _selectedCategoryId;

      // 搜索过滤
      bool searchMatch = _searchKeyword.isEmpty || _searchInRecipe(recipe);

      return _searchKeyword.isEmpty ? categoryMatch : searchMatch;
    }).toList();

    notifyListeners();
  }

  /// 在菜谱中搜索
  bool _searchInRecipe(Recipe recipe) {
    final keyword = _searchKeyword.toLowerCase();
    return recipe.name.toLowerCase().contains(keyword) ||
        recipe.desc.toLowerCase().contains(keyword) ||
        recipe.ingredients.any((ing) => ing.name.toLowerCase().contains(keyword)) ||
        recipe.steps.any((step) => step.toLowerCase().contains(keyword));
  }

  /// 根据ID获取菜谱
  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据分类获取菜谱
  List<Recipe> getRecipesByCategory(String categoryId) {
    return _recipes.where((recipe) => recipe.categoryId == categoryId).toList();
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String recipeId) async {
    try {
      final recipe = getRecipeById(recipeId);
      if (recipe != null) {
        final updatedRecipe = recipe.copyWith(
          favorite: !recipe.favorite,
        );

        await _dbService.updateRecipe(updatedRecipe);

        // 更新本地数据
        final index = _recipes.indexWhere((r) => r.id == recipeId);
        if (index >= 0) {
          _recipes[index] = updatedRecipe;
        }

        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '切换收藏状态失败: $e';
      notifyListeners();
    }
  }

  /// 添加菜谱
  Future<void> addRecipe(Recipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.insertRecipe(recipe);
      await _loadRecipes();
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '添加菜谱失败: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 更新菜谱
  Future<void> updateRecipe(Recipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.updateRecipe(recipe);
      await _loadRecipes();
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '更新菜谱失败: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 删除菜谱
  Future<void> deleteRecipe(String recipeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.deleteRecipe(recipeId);
      await _loadRecipes();
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '删除菜谱失败: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 添加分类
  Future<void> addCategory(String name) async {
    try {
      // 检查分类是否已存在
      if (_categories.any((cat) => cat.name == name)) {
        _errorMessage = '分类已存在';
        notifyListeners();
        return;
      }

      final newCategory = Category(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        name: name,
      );

      await _dbService.insertCategory(newCategory);
      await _loadCategories();

      notifyListeners();
    } catch (e) {
      _errorMessage = '添加分类失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 搜索菜谱（返回结果）
  List<Recipe> searchRecipes(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return _recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerKeyword) ||
          recipe.desc.toLowerCase().contains(lowerKeyword) ||
          recipe.ingredients.any((ing) => ing.name.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}