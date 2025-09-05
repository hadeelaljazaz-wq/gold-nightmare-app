class UserProfileModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      role: UserRole.fromString(map['role'] as String),
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isAdmin => role == UserRole.admin;
  bool get isPremium => role == UserRole.premium;
  bool get isStandard => role == UserRole.standard;

  String get displayRole => role.displayName;
  String get shortRole => role.shortName;

  String get initials {
    final names = fullName.split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first.substring(0, 1).toUpperCase();
    return (names.first.substring(0, 1) + names.last.substring(0, 1))
        .toUpperCase();
  }

  String get firstName {
    final names = fullName.split(' ');
    return names.isNotEmpty ? names.first : '';
  }

  String get lastName {
    final names = fullName.split(' ');
    return names.length > 1 ? names.last : '';
  }

  String get formattedJoinDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

// Re-export UserRole enum from license_model.dart to avoid duplication
enum UserRole {
  admin,
  premium,
  standard;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.standard,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.premium:
        return 'Premium User';
      case UserRole.standard:
        return 'Standard User';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.premium:
        return 'Premium';
      case UserRole.standard:
        return 'Standard';
    }
  }
}
