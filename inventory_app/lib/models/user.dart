enum UserRole {
  admin, // مدير
  manager, // مشرف
  user, // مستخدم
  accountant, // محاسب
}

class User {
  final String id;
  final String name;
  final String username;
  final String password;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('=== تحويل JSON إلى كائن User ===');
      print('البيانات الواردة: $json');

      final roleString = json['role'];
      print('نص الدور: $roleString');

      UserRole role;
      try {
        // محاولة تحويل الدور بطريقة أكثر أماناً
        switch (roleString) {
          case 'admin':
            role = UserRole.admin;
            break;
          case 'manager':
            role = UserRole.manager;
            break;
          case 'user':
            role = UserRole.user;
            break;
          case 'accountant':
            role = UserRole.accountant;
            break;
          default:
            print('دور غير معروف: $roleString، استخدام admin كافتراضي');
            role = UserRole.admin;
        }
        print('الدور المحول: $role');
      } catch (e) {
        print('خطأ في تحويل الدور، استخدام admin كافتراضي: $e');
        role = UserRole.admin;
      }

      // إصلاح مشكلة is_active - التعامل مع القيم المختلفة
      bool isActive;
      final isActiveValue = json['is_active'];
      if (isActiveValue == null) {
        isActive = true; // افتراضي
      } else if (isActiveValue is bool) {
        isActive = isActiveValue;
      } else if (isActiveValue is int) {
        isActive = isActiveValue == 1;
      } else if (isActiveValue is String) {
        isActive =
            isActiveValue.toLowerCase() == 'true' || isActiveValue == '1';
      } else {
        isActive = true; // افتراضي
      }
      print('حالة التفعيل: $isActive');

      // إصلاح مشكلة التاريخ
      DateTime createdAt;
      final createdAtValue = json['created_at'];
      if (createdAtValue is String) {
        createdAt = DateTime.parse(createdAtValue);
      } else if (createdAtValue is DateTime) {
        createdAt = createdAtValue;
      } else {
        createdAt = DateTime.now(); // افتراضي
      }

      final user = User(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        role: role,
        createdAt: createdAt,
        isActive: isActive,
      );

      print('✅ تم إنشاء كائن User بنجاح');
      return user;
    } catch (e) {
      print('❌ خطأ في تحويل JSON إلى User: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'role': role.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.manager:
        return 'مشرف';
      case UserRole.user:
        return 'مستخدم';
      case UserRole.accountant:
        return 'محاسب';
    }
  }

  bool get canManageUsers => role == UserRole.admin;
  bool get canManageInventory =>
      role == UserRole.admin || role == UserRole.manager;
  bool get canViewReports => role == UserRole.admin || role == UserRole.manager;
  bool get canExportData => role == UserRole.admin || role == UserRole.manager;
}
