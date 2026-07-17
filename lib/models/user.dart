class User {
  final String name;
  final String avatar;
  final String family;
  final String role; // 'owner' 或 'member'

  User({
    required this.name,
    required this.avatar,
    required this.family,
    this.role = 'owner',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      family: json['family'] as String,
      role: json['role'] as String? ?? 'owner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'family': family,
      'role': role,
    };
  }

  User copyWith({
    String? name,
    String? avatar,
    String? family,
    String? role,
  }) {
    return User(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      family: family ?? this.family,
      role: role ?? this.role,
    );
  }

  // 是否为群主
  bool get isOwner => role == 'owner';
}