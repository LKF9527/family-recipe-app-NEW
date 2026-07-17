import '../services/database_service.dart';
import '../models/recipe.dart';
import '../models/category.dart';
import '../models/member.dart';
import '../models/user.dart';
import '../models/menu.dart';

/// 数据迁移服务 - 将微信小程序的数据转换为Flutter应用格式
class DataMigrationService {
  final DatabaseService _dbService = DatabaseService();

  bool _isMigrated = false;

  /// 执行完整的数据迁移
  Future<void> migrateData() async {
    if (_isMigrated) {
      print('数据已经迁移过了，跳过重复迁移。');
      return;
    }

    try {
      print('开始数据迁移...');

      // 迁移分类数据
      await _migrateCategories();

      // 迁移菜谱数据
      await _migrateRecipes();

      // 迁移成员数据
      await _migrateMembers();

      // 迁移用户数据
      await _migrateUser();

      // 迁移菜单数据
      await _migrateMenus();

      _isMigrated = true;
      print('数据迁移完成！');
    } catch (e) {
      print('数据迁移失败: $e');
      rethrow;
    }
  }

  /// 迁移分类数据
  Future<void> _migrateCategories() async {
    print('迁移分类数据...');

    final categories = _getDefaultCategories();

    for (var category in categories) {
      await _dbService.insertCategory(category);
    }

    print('分类数据迁移完成: ${categories.length} 个分类');
  }

  /// 迁移菜谱数据
  Future<void> _migrateRecipes() async {
    print('迁移菜谱数据...');

    final recipes = _getDefaultRecipes();

    for (var recipe in recipes) {
      await _dbService.insertRecipe(recipe);
    }

    print('菜谱数据迁移完成: ${recipes.length} 个菜谱');
  }

  /// 迁移成员数据
  Future<void> _migrateMembers() async {
    print('迁移成员数据...');

    final members = _getDefaultMembers();

    for (var member in members) {
      await _dbService.insertMember(member);
    }

    print('成员数据迁移完成: ${members.length} 个成员');
  }

  /// 迁移用户数据
  Future<void> _migrateUser() async {
    print('迁移用户数据...');

    final user = _getDefaultUser();

    await _dbService.updateUser(user);

    print('用户数据迁移完成: ${user.name}');
  }

  /// 迁移菜单数据
  Future<void> _migrateMenus() async {
    print('迁移菜单数据...');

    // 小程序初始菜单数据为空，这里只是初始化
    final menus = <Menu>[];

    for (var menu in menus) {
      await _dbService.insertMenu(menu);
    }

    print('菜单数据迁移完成: ${menus.length} 个菜单日期');
  }

  // 检查是否已迁移
  Future<bool> isMigrated() async {
    final recipes = await _dbService.getRecipes();
    return recipes.isNotEmpty;
  }

  // 以下是微信小程序的原始数据转换

  List<Category> _getDefaultCategories() {
    return [
      Category(id: 'c1', name: '家常菜'),
      Category(id: 'c2', name: '汤羹'),
      Category(id: 'c3', name: '主食'),
      Category(id: 'c4', name: '轻食'),
    ];
  }

  List<Recipe> _getDefaultRecipes() {
    return [
      Recipe(
        id: 'r1',
        categoryId: 'c1',
        name: '番茄炒蛋',
        desc: '酸甜开胃，全家都爱',
        emoji: '🍅',
        color: '#f8d4c5',
        ingredients: [
          IngredientItem(name: '番茄', amount: '2个'),
          IngredientItem(name: '鸡蛋', amount: '3枚'),
          IngredientItem(name: '香葱', amount: '1根'),
        ],
        seasonings: [
          IngredientItem(name: '盐', amount: '2克'),
          IngredientItem(name: '白糖', amount: '5克'),
          IngredientItem(name: '食用油', amount: '15毫升'),
        ],
        steps: [
          '番茄洗净切成小块，鸡蛋加入少许盐打散。',
          '热锅倒油，将蛋液炒至蓬松后盛出。',
          '留底油炒软番茄，加入白糖和盐。',
          '倒回鸡蛋翻炒均匀，撒上葱花即可。'
        ],
        favorite: true,
      ),
      Recipe(
        id: 'r2',
        categoryId: 'c1',
        name: '可乐鸡翅',
        desc: '色泽红亮，鲜香入味',
        emoji: '🍗',
        color: '#e9c5ad',
        ingredients: [
          IngredientItem(name: '鸡翅中', amount: '10个'),
          IngredientItem(name: '姜', amount: '3片'),
        ],
        seasonings: [
          IngredientItem(name: '可乐', amount: '330毫升'),
          IngredientItem(name: '生抽', amount: '20毫升'),
          IngredientItem(name: '老抽', amount: '5毫升'),
        ],
        steps: [
          '鸡翅洗净后两面划刀，冷水下锅焯水。',
          '锅内少油，将鸡翅煎至两面金黄。',
          '加入姜片、生抽、老抽和可乐。',
          '中火焖煮20分钟，大火收汁。'
        ],
        favorite: false,
      ),
      Recipe(
        id: 'r3',
        categoryId: 'c1',
        name: '清炒西兰花',
        desc: '清爽脆嫩，简单健康',
        emoji: '🥦',
        color: '#d5e7ca',
        ingredients: [
          IngredientItem(name: '西兰花', amount: '1颗'),
          IngredientItem(name: '蒜', amount: '3瓣'),
        ],
        seasonings: [
          IngredientItem(name: '盐', amount: '2克'),
          IngredientItem(name: '食用油', amount: '10毫升'),
        ],
        steps: [
          '西兰花切小朵，用盐水浸泡后洗净。',
          '沸水中滴油，将西兰花焯水1分钟。',
          '热锅爆香蒜末，倒入西兰花。',
          '大火翻炒，加盐调味后出锅。'
        ],
        favorite: true,
      ),
      Recipe(
        id: 'r4',
        categoryId: 'c2',
        name: '玉米排骨汤',
        desc: '清甜滋润，暖心暖胃',
        emoji: '🌽',
        color: '#f4e3ad',
        ingredients: [
          IngredientItem(name: '排骨', amount: '500克'),
          IngredientItem(name: '甜玉米', amount: '1根'),
          IngredientItem(name: '胡萝卜', amount: '1根'),
        ],
        seasonings: [
          IngredientItem(name: '盐', amount: '3克'),
          IngredientItem(name: '姜', amount: '3片'),
        ],
        steps: [
          '排骨冷水下锅焯去血沫，洗净。',
          '玉米切段，胡萝卜切滚刀块。',
          '所有食材放入锅中，加足量清水。',
          '炖煮60分钟，出锅前加盐。'
        ],
        favorite: false,
      ),
      Recipe(
        id: 'r5',
        categoryId: 'c3',
        name: '香菇鸡肉焖饭',
        desc: '一锅搞定，饭菜喷香',
        emoji: '🍚',
        color: '#dfcfb8',
        ingredients: [
          IngredientItem(name: '大米', amount: '2杯'),
          IngredientItem(name: '鸡腿肉', amount: '250克'),
          IngredientItem(name: '香菇', amount: '6朵'),
        ],
        seasonings: [
          IngredientItem(name: '生抽', amount: '15毫升'),
          IngredientItem(name: '蚝油', amount: '10克'),
        ],
        steps: [
          '鸡腿肉切块，香菇切片。',
          '鸡肉炒至变色，加入香菇和调料。',
          '大米洗净，铺上炒好的食材。',
          '按正常煮饭水量焖熟，拌匀。'
        ],
        favorite: false,
      ),
      Recipe(
        id: 'r6',
        categoryId: 'c4',
        name: '鲜虾牛油果沙拉',
        desc: '低负担的缤纷一餐',
        emoji: '🥗',
        color: '#dce7c4',
        ingredients: [
          IngredientItem(name: '鲜虾', amount: '8只'),
          IngredientItem(name: '牛油果', amount: '1个'),
          IngredientItem(name: '生菜', amount: '150克'),
        ],
        seasonings: [
          IngredientItem(name: '橄榄油', amount: '10毫升'),
          IngredientItem(name: '黑胡椒', amount: '1克'),
        ],
        steps: [
          '鲜虾去壳去线煮熟。',
          '蔬菜洗净沥干，牛油果切块。',
          '所有食材装盘。',
          '淋橄榄油，研磨黑胡椒拌匀。'
        ],
        favorite: false,
      ),
    ];
  }

  List<Member> _getDefaultMembers() {
    return [
      Member(id: 'm1', name: '林小满', role: '创建者', avatar: '林', color: '#e79c75'),
      Member(id: 'm2', name: '陈先生', role: '家庭成员', avatar: '陈', color: '#7b9f87'),
      Member(id: 'm3', name: '奶奶', role: '家庭成员', avatar: '奶', color: '#c69c74'),
    ];
  }

  User _getDefaultUser() {
    return User(
      name: '林小满',
      avatar: '林',
      family: '小满一家',
      role: 'owner',
    );
  }

  /// 将微信小程序的原始数据格式转换为Recipe对象
  /// 原始格式：ingredients: [[name, amount], ...]
  static Recipe convertFromMiniprogram(Map<String, dynamic> data) {
    final ingredients = (data['ingredients'] as List<List<dynamic>>)
        .map((item) => IngredientItem(
              name: item[0].toString(),
              amount: item.length > 1 ? item[1].toString() : '',
            ))
        .toList();

    final seasonings = (data['seasonings'] as List<List<dynamic>>)
        .map((item) => IngredientItem(
              name: item[0].toString(),
              amount: item.length > 1 ? item[1].toString() : '',
            ))
        .toList();

    return Recipe(
      id: data['id'] as String,
      categoryId: data['categoryId'] as String,
      name: data['name'] as String,
      desc: data['desc'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '🍳',
      color: data['color'] as String? ?? '#cccccc',
      coverPath: data['coverPath'] as String?,
      ingredients: ingredients,
      seasonings: seasonings,
      steps: (data['steps'] as List<dynamic>).cast<String>(),
      favorite: data['favorite'] as bool? ?? false,
    );
  }

  /// 批量导入菜谱数据
  Future<void> importRecipes(List<Map<String, dynamic>> recipesData) async {
    for (var recipeData in recipesData) {
      final recipe = convertFromMiniprogram(recipeData);
      await _dbService.insertRecipe(recipe);
    }
  }

  /// 导出数据为JSON格式（用于备份）
  Future<Map<String, dynamic>> exportData() async {
    final recipes = await _dbService.getRecipes();
    final categories = await _dbService.getCategories();
    final members = await _dbService.getMembers();
    final user = await _dbService.getUser();
    final menus = await _dbService.getMenus();

    return {
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'members': members.map((m) => m.toJson()).toList(),
      'user': user?.toJson(),
      'menus': menus.map((m) => m.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// 从JSON导入数据（用于恢复）
  Future<void> importData(Map<String, dynamic> data) async {
    // 清空现有数据
    await _dbService.clearAllData();

    // 导入分类
    final categories = (data['categories'] as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
    for (var category in categories) {
      await _dbService.insertCategory(category);
    }

    // 导入菜谱
    final recipes = (data['recipes'] as List)
        .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
        .toList();
    for (var recipe in recipes) {
      await _dbService.insertRecipe(recipe);
    }

    // 导入成员
    final members = (data['members'] as List)
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();
    for (var member in members) {
      await _dbService.insertMember(member);
    }

    // 导入用户
    if (data['user'] != null) {
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await _dbService.updateUser(user);
    }

    // 导入菜单
    final menus = (data['menus'] as List)
        .map((json) => Menu.fromJson(json as Map<String, dynamic>))
        .toList();
    for (var menu in menus) {
      await _dbService.insertMenu(menu);
    }

    _isMigrated = true;
    print('数据导入完成！');
  }
}