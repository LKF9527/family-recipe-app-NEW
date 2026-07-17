class Member {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final String color;

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.color,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatar': avatar,
      'color': color,
    };
  }

  Member copyWith({
    String? id,
    String? name,
    String? role,
    String? avatar,
    String? color,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
    );
  }

  // 是否为群主
  bool get isOwner => role == '创建者';
}