class Recipe {
  final String id;
  final String categoryId;
  final String name;
  final String desc;
  final String emoji;
  final String color;
  final String? coverPath;
  final List<IngredientItem> ingredients;
  final List<IngredientItem> seasonings;
  final List<String> steps;
  final bool favorite;

  Recipe({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.desc,
    required this.emoji,
    required this.color,
    this.coverPath,
    required this.ingredients,
    required this.seasonings,
    required this.steps,
    this.favorite = false,
  });

  // 从JSON创建（用于SQLite存储）
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      desc: json['desc'] as String,
      emoji: json['emoji'] as String,
      color: json['color'] as String,
      coverPath: json['coverPath'] as String?,
      ingredients: (json['ingredients'] as List)
          .map((item) => IngredientItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      seasonings: (json['seasonings'] as List)
          .map((item) => IngredientItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List).cast<String>(),
      favorite: json['favorite'] == 1,
    );
  }

  // 转换为JSON（用于SQLite存储）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'desc': desc,
      'emoji': emoji,
      'color': color,
      'coverPath': coverPath,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
      'seasonings': seasonings.map((item) => item.toJson()).toList(),
      'steps': steps,
      'favorite': favorite ? 1 : 0,
    };
  }

  // 复制并修改部分字段
  Recipe copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? desc,
    String? emoji,
    String? color,
    String? coverPath,
    List<IngredientItem>? ingredients,
    List<IngredientItem>? seasonings,
    List<String>? steps,
    bool? favorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      coverPath: coverPath ?? this.coverPath,
      ingredients: ingredients ?? this.ingredients,
      seasonings: seasonings ?? this.seasonings,
      steps: steps ?? this.steps,
      favorite: favorite ?? this.favorite,
    );
  }
}

class IngredientItem {
  final String name;
  final String amount;

  IngredientItem({
    required this.name,
    required this.amount,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      name: json['name'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }

  // 从原来的二元数组格式转换
  static IngredientItem fromList(List<String> list) {
    return IngredientItem(
      name: list.length > 0 ? list[0] : '',
      amount: list.length > 1 ? list[1] : '',
    );
  }

  // 转换为二元数组格式
  List<String> toList() {
    return [name, amount];
  }
}