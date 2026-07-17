class Menu {
  final String date; // 格式: "2026-07-17"
  final List<String> recipeIds; // 菜谱ID列表

  Menu({
    required this.date,
    required this.recipeIds,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      date: json['date'] as String,
      recipeIds: (json['recipeIds'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'recipeIds': recipeIds,
    };
  }

  Menu copyWith({
    String? date,
    List<String>? recipeIds,
  }) {
    return Menu(
      date: date ?? this.date,
      recipeIds: recipeIds ?? this.recipeIds,
    );
  }

  // 添加菜谱
  Menu addRecipe(String recipeId) {
    if (recipeIds.contains(recipeId)) {
      return this;
    }
    return Menu(
      date: date,
      recipeIds: [...recipeIds, recipeId],
    );
  }

  // 移除菜谱
  Menu removeRecipe(String recipeId) {
    return Menu(
      date: date,
      recipeIds: recipeIds.where((id) => id != recipeId).toList(),
    );
  }

  // 清空当天菜单
  Menu clear() {
    return Menu(
      date: date,
      recipeIds: [],
    );
  }
}