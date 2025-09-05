class LicenseModel {
  final String id;
  final String keyValue;
  final String? userId;
  final UserRole planType;
  final LicenseStatus status;
  final int usageCount;
  final int usageLimit;
  final DateTime? expiresAt;
  final DateTime? activatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? maxDevices;
  final String? securityLevel;
  final bool isFixedAdmin;

  const LicenseModel({
    required this.id,
    required this.keyValue,
    this.userId,
    required this.planType,
    required this.status,
    required this.usageCount,
    required this.usageLimit,
    this.expiresAt,
    this.activatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.maxDevices,
    this.securityLevel,
    this.isFixedAdmin = false,
  });

  factory LicenseModel.fromMap(Map<String, dynamic> map) {
    return LicenseModel(
      id: map['id'] as String,
      keyValue: map['key_value'] as String,
      userId: map['user_id'] as String?,
      planType: UserRole.fromString(map['plan_type'] as String),
      status: LicenseStatus.fromString(map['status'] as String),
      usageCount: map['usage_count'] as int,
      usageLimit: map['usage_limit'] as int,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      activatedAt: map['activated_at'] != null
          ? DateTime.parse(map['activated_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      maxDevices: map['max_devices'] as int?,
      securityLevel: map['security_level'] as String?,
      isFixedAdmin: map['is_fixed_admin'] as bool? ?? false,
    );
  }

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      id: json['id'] as String,
      keyValue: json['key_value'] as String,
      userId: json['user_id'] as String?,
      planType: UserRole.fromString(json['plan_type'] as String),
      status: LicenseStatus.fromString(json['status'] as String),
      usageCount: json['usage_count'] as int,
      usageLimit: json['usage_limit'] as int,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      maxDevices: json['max_devices'] as int?,
      securityLevel: json['security_level'] as String?,
      isFixedAdmin: json['is_fixed_admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key_value': keyValue,
      'user_id': userId,
      'plan_type': planType.name,
      'status': status.name,
      'usage_count': usageCount,
      'usage_limit': usageLimit,
      'expires_at': expiresAt?.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'max_devices': maxDevices,
      'security_level': securityLevel,
      'is_fixed_admin': isFixedAdmin,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key_value': keyValue,
      'user_id': userId,
      'plan_type': planType.name,
      'status': status.name,
      'usage_count': usageCount,
      'usage_limit': usageLimit,
      'expires_at': expiresAt?.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'max_devices': maxDevices,
      'security_level': securityLevel,
      'is_fixed_admin': isFixedAdmin,
    };
  }

  LicenseModel copyWith({
    String? id,
    String? keyValue,
    String? userId,
    UserRole? planType,
    LicenseStatus? status,
    int? usageCount,
    int? usageLimit,
    DateTime? expiresAt,
    DateTime? activatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? maxDevices,
    String? securityLevel,
    bool? isFixedAdmin,
  }) {
    return LicenseModel(
      id: id ?? this.id,
      keyValue: keyValue ?? this.keyValue,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      usageCount: usageCount ?? this.usageCount,
      usageLimit: usageLimit ?? this.usageLimit,
      expiresAt: expiresAt ?? this.expiresAt,
      activatedAt: activatedAt ?? this.activatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maxDevices: maxDevices ?? this.maxDevices,
      securityLevel: securityLevel ?? this.securityLevel,
      isFixedAdmin: isFixedAdmin ?? this.isFixedAdmin,
    );
  }

  // Helper getters
  bool get isActive => status == LicenseStatus.active;
  bool get isExpired => status == LicenseStatus.expired;
  bool get isSuspended => status == LicenseStatus.suspended;
  bool get isPending => status == LicenseStatus.pending;
  bool get isActivated => userId != null && activatedAt != null;

  int get remainingUsage => usageLimit - usageCount;
  double get usagePercentage => (usageCount / usageLimit * 100);

  bool get hasUsageRemaining => remainingUsage > 0;

  bool get isExpiredByDate {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  String get formattedExpirationDate {
    if (expiresAt == null) return 'No expiration';
    return '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}';
  }

  String get usageStatus => '$usageCount / $usageLimit analyses used';
}

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

enum LicenseStatus {
  active,
  expired,
  suspended,
  pending;

  static LicenseStatus fromString(String value) {
    return LicenseStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => LicenseStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case LicenseStatus.active:
        return 'Active';
      case LicenseStatus.expired:
        return 'Expired';
      case LicenseStatus.suspended:
        return 'Suspended';
      case LicenseStatus.pending:
        return 'Pending';
    }
  }
}
