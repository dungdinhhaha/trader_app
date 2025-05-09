class User {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  User({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    this.lastSignInAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['user_metadata']?['full_name'] as String?,
      avatarUrl: json['user_metadata']?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSignInAt:
          json['last_sign_in_at'] != null
              ? DateTime.parse(json['last_sign_in_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {'full_name': fullName, 'avatar_url': avatarUrl},
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
