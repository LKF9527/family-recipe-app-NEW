import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';
import '../models/category.dart';
import '../models/menu.dart';
import '../models/member.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'family_recipe.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // 创建菜谱表
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        name TEXT NOT NULL,
        desc TEXT,
        emoji TEXT,
        color TEXT,
        coverPath TEXT,
        ingredients TEXT NOT NULL,
        seasonings TEXT NOT NULL,
        steps TEXT NOT NULL,
        favorite INTEGER DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // 创建菜单表
    await db.execute('''
      CREATE TABLE menus (
        date TEXT PRIMARY KEY,
        recipeIds TEXT NOT NULL
      )
    ''');

    // 创建成员表
    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        avatar TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    // 创建用户表
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        family TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // 创建设置表
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 初始化默认数据
    await _initDefaultData(db);
  }

  Future<void> _initDefaultData(Database db) async {
    // 默认分类
    final defaultCategories = [
      Category(id: 'c1', name: '家常菜'),
      Category(id: 'c2', name: '汤羹'),
      Category(id: 'c3', name: '主食'),
      Category(id: 'c4', name: '轻食'),
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category.toJson());
    }

    // 默认用户
    final defaultUser = User(
      name: '林小满',
      avatar: '林',
      family: '小满一家',
      role: 'owner',
    );
    await db.insert('user', defaultUser.toJson());

    // 默认成员
    final defaultMembers = [
      Member(id: 'm1', name: '林小满', role: '创建者', avatar: '林', color: '#e79c75'),
      Member(id: 'm2', name: '陈先生', role: '家庭成员', avatar: '陈', color: '#7b9f87'),
      Member(id: 'm3', name: '奶奶', role: '家庭成员', avatar: '奶', color: '#c69c74'),
    ];

    for (var member in defaultMembers) {
      await db.insert('members', member.toJson());
    }

    // 默认菜谱
    final defaultRecipes = [
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

    for (var recipe in defaultRecipes) {
      await db.insert('recipes', recipe.toJson());
    }
  }

  // 菜谱操作
  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) => Recipe.fromJson(maps[i]));
  }

  Future<Recipe?> getRecipeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Recipe.fromJson(maps.first);
  }

  Future<List<Recipe>> getRecipesByCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Recipe.fromJson(maps[i]));
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'favorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Recipe.fromJson(maps[i]));
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert('recipes', recipe.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.update(
      'recipes',
      recipe.toJson(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<void> deleteRecipe(String id) async {
    final db = await database;
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 分类操作
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 菜单操作
  Future<List<Menu>> getMenus() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('menus');
    return List.generate(maps.length, (i) => Menu.fromJson(maps[i]));
  }

  Future<Menu?> getMenuByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'menus',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return Menu.fromJson(maps.first);
  }

  Future<void> insertMenu(Menu menu) async {
    final db = await database;
    await db.insert('menus', menu.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateMenu(Menu menu) async {
    final db = await database;
    await db.update(
      'menus',
      menu.toJson(),
      where: 'date = ?',
      whereArgs: [menu.date],
    );
  }

  Future<void> deleteMenu(String date) async {
    final db = await database;
    await db.delete(
      'menus',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // 成员操作
  Future<List<Member>> getMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('members');
    return List.generate(maps.length, (i) => Member.fromJson(maps[i]));
  }

  Future<void> insertMember(Member member) async {
    final db = await database;
    await db.insert('members', member.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMember(String id) async {
    final db = await database;
    await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 用户操作
  Future<User?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user', limit: 1);
    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    final existing = await db.query('user', limit: 1);
    if (existing.isEmpty) {
      await db.insert('user', user.toJson());
    } else {
      await db.update('user', user.toJson());
    }
  }

  // 设置操作
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 清空所有数据（用于重置）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('recipes');
    await db.delete('categories');
    await db.delete('menus');
    await db.delete('members');
    await db.delete('user');
    await db.delete('settings');

    // 重新初始化默认数据
    await _initDefaultData(db);
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}