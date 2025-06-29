import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _databaseService = DatabaseService();
  final supabase = supabase_flutter.Supabase.instance.client;

  // تسجيل الدخول
  Future<User?> login(String username, String password) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .eq('password', password)
        .eq('is_active', true)
        .maybeSingle();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  // البحث عن مستخدم بواسطة اسم المستخدم
  Future<User?> getUserByUsername(String username) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  // التحقق من وجود مستخدمين في النظام
  Future<bool> hasUsers() async {
    try {
      final users = await _databaseService.getAllUsers();
      print('عدد المستخدمين في النظام: ${users.length}');
      return users.isNotEmpty;
    } catch (e) {
      print('خطأ في التحقق من المستخدمين: $e');
      return false;
    }
  }

  // إنشاء مستخدم افتراضي إذا لم يكن هناك مستخدمين
  Future<void> createDefaultUser() async {
    try {
      print('=== بدء إنشاء المستخدم الافتراضي ===');
      final hasUsers = await this.hasUsers();
      if (!hasUsers) {
        print('لا يوجد مستخدمين، سيتم إنشاء المستخدم الافتراضي');

        // إنشاء بيانات المستخدم بدون معرف (سيتم إنشاؤه تلقائياً)
        final userData = {
          'name': 'مدير النظام',
          'username': 'admin',
          'password': 'admin123',
          'role': 'admin',
          'is_active': true,
        };

        print('بيانات المستخدم الافتراضي:');
        print('  - الاسم: ${userData['name']}');
        print('  - اسم المستخدم: ${userData['username']}');
        print('  - كلمة المرور: ${userData['password']}');
        print('  - الدور: ${userData['role']}');
        print('  - مفعل: ${userData['is_active']}');

        // إدراج المستخدم في Supabase (بدون معرف)
        await supabase.from('users').insert(userData);
        print('✅ تم إنشاء المستخدم الافتراضي بنجاح');

        // التحقق من إنشاء المستخدم
        final createdUser = await getUserByUsername('admin');
        if (createdUser != null) {
          print('✅ تم التحقق من إنشاء المستخدم الافتراضي بنجاح');
          print('  - المعرف: ${createdUser.id}');
          print('  - اسم المستخدم: ${createdUser.username}');
          print('  - كلمة المرور: ${createdUser.password}');
          print('  - الدور: ${createdUser.role}');
          print('  - مفعل: ${createdUser.isActive}');
        } else {
          print('❌ فشل في التحقق من إنشاء المستخدم الافتراضي');
        }
      } else {
        print('يوجد مستخدمين بالفعل، لن يتم إنشاء المستخدم الافتراضي');

        // عرض المستخدمين الموجودين
        final users = await _databaseService.getAllUsers();
        print('المستخدمين الموجودين:');
        for (var user in users) {
          print('  - ${user.username} (${user.name}) - ${user.role}');
        }
      }
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم الافتراضي: $e');
      print('تفاصيل الخطأ: ${e.toString()}');
    }
  }

  // حذف جميع المستخدمين (للتطوير فقط)
  Future<void> clearAllUsers() async {
    try {
      print('حذف جميع المستخدمين...');
      final users = await _databaseService.getAllUsers();
      for (var user in users) {
        await _databaseService.deleteUser(user.id);
      }
      print('تم حذف جميع المستخدمين');
    } catch (e) {
      print('خطأ في حذف المستخدمين: $e');
    }
  }
}
