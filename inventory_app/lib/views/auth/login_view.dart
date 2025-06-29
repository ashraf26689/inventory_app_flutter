import 'package:flutter/material.dart';
import '../../constants/app_texts.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class LoginView extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const LoginView({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _isArabic = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDefaultUser();
  }

  void _initializeDefaultUser() async {
    await _authService.createDefaultUser();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        print('=== محاولة تسجيل الدخول ===');
        print('اسم المستخدم: "$_username"');
        print('كلمة المرور: "$_password"');

        // التحقق من صحة المدخلات
        if (_username.trim().isEmpty || _password.trim().isEmpty) {
          setState(() {
            _errorMessage = _isArabic
                ? 'يرجى إدخال اسم المستخدم وكلمة المرور'
                : 'Please enter username and password';
          });
          return;
        }

        final user =
            await _authService.login(_username.trim(), _password.trim());

        if (user != null) {
          print('✅ تسجيل الدخول ناجح، الانتقال إلى لوحة التحكم');
          print('معلومات المستخدم:');
          print('  - الاسم: ${user.name}');
          print('  - الدور: ${user.role}');
          print('  - مفعل: ${user.isActive}');

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          print('❌ فشل تسجيل الدخول');
          setState(() {
            _errorMessage = _isArabic
                ? 'اسم المستخدم أو كلمة المرور غير صحيحة'
                : 'Invalid username or password';
          });
        }
      } catch (e) {
        print('❌ خطأ في تسجيل الدخول: $e');
        print('تفاصيل الخطأ: ${e.toString()}');
        setState(() {
          _errorMessage = _isArabic
              ? 'حدث خطأ أثناء تسجيل الدخول'
              : 'An error occurred during login';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _recreateDefaultUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('=== إعادة إنشاء المستخدم الافتراضي ===');

      // حذف جميع المستخدمين
      await _authService.clearAllUsers();
      print('✅ تم حذف جميع المستخدمين');

      // إنشاء المستخدم الافتراضي
      await _authService.createDefaultUser();
      print('✅ تم إنشاء المستخدم الافتراضي');

      // التحقق من إنشاء المستخدم
      final testUser = await _authService.login('admin', 'admin123');
      if (testUser != null) {
        print('✅ تم التحقق من إنشاء المستخدم الافتراضي بنجاح');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isArabic
                  ? 'تم إعادة إنشاء المستخدم الافتراضي بنجاح'
                  : 'Default user recreated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      } else {
        print('❌ فشل في التحقق من إنشاء المستخدم الافتراضي');
        if (mounted) {
          setState(() {
            _errorMessage = _isArabic
                ? 'فشل في إنشاء المستخدم الافتراضي'
                : 'Failed to create default user';
          });
        }
      }
    } catch (e) {
      print('❌ خطأ في إعادة إنشاء المستخدم: $e');
      print('تفاصيل الخطأ: ${e.toString()}');
      if (mounted) {
        setState(() {
          _errorMessage = _isArabic
              ? 'حدث خطأ أثناء إعادة إنشاء المستخدم'
              : 'An error occurred while recreating user';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
      _errorMessage = null;
      widget.onLocaleChange(Locale(_isArabic ? 'ar' : 'en'));
    });
  }

  void _restartApp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('=== إعادة تشغيل التطبيق ===');

      // حذف جميع المستخدمين
      await _authService.clearAllUsers();
      print('✅ تم حذف جميع المستخدمين');

      // إعادة إنشاء المستخدم الافتراضي
      await _authService.createDefaultUser();
      print('✅ تم إعادة إنشاء المستخدم الافتراضي');

      // اختبار تسجيل الدخول
      final testUser = await _authService.login('admin', 'admin123');
      if (testUser != null) {
        print('✅ تم التحقق من إعادة تشغيل التطبيق بنجاح');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isArabic
                  ? 'تم إعادة تشغيل التطبيق بنجاح'
                  : 'App restarted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );

          // إعادة تحميل الصفحة
          setState(() {
            _username = '';
            _password = '';
            _errorMessage = null;
          });
        }
      } else {
        print('❌ فشل في التحقق من إعادة تشغيل التطبيق');
        if (mounted) {
          setState(() {
            _errorMessage = _isArabic
                ? 'فشل في إعادة تشغيل التطبيق'
                : 'Failed to restart app';
          });
        }
      }
    } catch (e) {
      print('❌ خطأ في إعادة تشغيل التطبيق: $e');
      print('تفاصيل الخطأ: ${e.toString()}');
      if (mounted) {
        setState(() {
          _errorMessage = _isArabic
              ? 'حدث خطأ أثناء إعادة تشغيل التطبيق'
              : 'An error occurred while restarting the app';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? double.infinity : 480,
              ),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppColors.cardGradient,
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== شعار التطبيق مع تأثير =====
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            size: isSmallScreen ? 56 : 72,
                            color: AppColors.textInverse,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ===== عنوان التطبيق =====
                        Text(
                          _isArabic ? AppTexts.appTitle : AppTexts.appTitleEn,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // ===== وصف التطبيق =====
                        Text(
                          _isArabic
                              ? 'نظام إدارة المخزون الذكي'
                              : 'Smart Inventory Management System',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // ===== رسالة الخطأ =====
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: AppColors.textInverse,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // ===== حقل اسم المستخدم =====
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: _isArabic
                                ? AppTexts.username
                                : AppTexts.usernameEn,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.textLight,
                            ),
                            suffixIcon: Icon(
                              Icons.person,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) => value == null || value.isEmpty
                              ? (_isArabic
                                  ? AppTexts.requiredField
                                  : AppTexts.requiredFieldEn)
                              : null,
                          onChanged: (value) => _username = value,
                        ),
                        const SizedBox(height: 24),

                        // ===== حقل كلمة المرور =====
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: _isArabic
                                ? AppTexts.password
                                : AppTexts.passwordEn,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.textLight,
                            ),
                            suffixIcon: Icon(
                              Icons.security,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty
                              ? (_isArabic
                                  ? AppTexts.requiredField
                                  : AppTexts.requiredFieldEn)
                              : null,
                          onChanged: (value) => _password = value,
                        ),
                        const SizedBox(height: 40),

                        // ===== زر تسجيل الدخول =====
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              foregroundColor: AppColors.textInverse,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textInverse,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _isArabic
                                            ? AppTexts.login
                                            : AppTexts.loginEn,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ===== معلومات تسجيل الدخول الافتراضية =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.infoLight,
                                AppColors.infoLight.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.info,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: AppColors.textInverse,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      _isArabic
                                          ? 'بيانات تسجيل الدخول الافتراضية:'
                                          : 'Default Login Credentials:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.info,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.info.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  _isArabic
                                      ? 'اسم المستخدم: admin\nكلمة المرور: admin123'
                                      : 'Username: admin\nPassword: admin123',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ===== أزرار إضافية =====
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _toggleLanguage,
                                icon: const Icon(Icons.language),
                                label: Text(_isArabic ? 'English' : 'العربية'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.buttonSecondary,
                                  side: BorderSide(
                                    color: AppColors.buttonSecondary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isLoading ? null : _recreateDefaultUser,
                                icon: const Icon(Icons.refresh),
                                label: Text(
                                  _isArabic ? 'إعادة إنشاء' : 'Recreate',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.buttonWarning,
                                  side: BorderSide(
                                    color: AppColors.buttonWarning,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ===== زر إعادة تشغيل التطبيق =====
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _restartApp,
                            icon: const Icon(Icons.restart_alt),
                            label: Text(
                              _isArabic ? 'إعادة تشغيل التطبيق' : 'Restart App',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.buttonError,
                              side: BorderSide(
                                color: AppColors.buttonError,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
