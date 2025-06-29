import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'views/auth/login_view.dart';
import 'features/dashboard/views/enhanced_dashboard_view.dart';
import 'views/items/item_list_view.dart';
import 'views/transactions/transaction_list_view.dart';
import 'views/reports/reports_view.dart';
import 'views/users/users_view.dart';
import 'views/settings/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://wwkyridwmjiwadmszsuw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3a3lyaWR3bWppd2FkbXN6c3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMjY3OTQsImV4cCI6MjA2NjcwMjc5NH0.zagW7eud5uV1B4EUv3IJg2MKgycLkiuTcQKU586_6vo',
  );

  print('✅ تم تهيئة Supabase بنجاح');

  // اختبار قاعدة البيانات
  print('=== اختبار قاعدة البيانات ===');
  final authService = AuthService();

  try {
    // إنشاء المستخدم الافتراضي
    print('جاري إنشاء المستخدم الافتراضي...');
    await authService.createDefaultUser();
    print('✅ تم إنشاء المستخدم الافتراضي');

    // التحقق من وجود المستخدم
    print('جاري التحقق من وجود المستخدم...');
    final hasUsers = await authService.hasUsers();
    if (hasUsers) {
      print('✅ يوجد مستخدمين في النظام');

      // اختبار البحث عن المستخدم
      final user = await authService.login('admin', 'admin123');
      if (user != null) {
        print('✅ اختبار تسجيل الدخول ناجح');
        print('معلومات المستخدم:');
        print('  - المعرف: ${user.id}');
        print('  - الاسم: ${user.name}');
        print('  - اسم المستخدم: ${user.username}');
        print('  - الدور: ${user.role}');
        print('  - مفعل: ${user.isActive}');
      } else {
        print('❌ اختبار تسجيل الدخول فشل');
      }
    } else {
      print('❌ لا يوجد مستخدمين في النظام');
    }

    // إنشاء بيانات تجريبية
    print('جاري إنشاء البيانات التجريبية...');
    final dbService = DatabaseService();
    await dbService.createSampleData();
    print('✅ تم إنشاء البيانات التجريبية');
  } catch (e) {
    print('❌ خطأ في اختبار قاعدة البيانات: $e');
    print('تفاصيل الخطأ: ${e.toString()}');
    print('نوع الخطأ: ${e.runtimeType}');
  }

  runApp(const InventoryApp());
}

class InventoryApp extends StatefulWidget {
  const InventoryApp({Key? key}) : super(key: key);

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  Locale _locale = const Locale('ar');
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة المخزون',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ===== دعم اللغات =====
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },

      // ===== دعم RTL =====
      builder: (context, child) {
        return Directionality(
          textDirection: _locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      // ===== الصفحة الرئيسية والروابط =====
      home: LoginView(onLocaleChange: setLocale),
      routes: {
        '/login': (context) => LoginView(onLocaleChange: setLocale),
        '/dashboard': (context) => const EnhancedDashboardView(),
        '/items': (context) => const ItemListView(),
        '/transactions': (context) => const TransactionListView(),
        '/reports': (context) => const ReportsView(),
        '/users': (context) => const UsersView(),
        '/settings': (context) => SettingsView(
              isDarkMode: _isDarkMode,
              onDarkModeChanged: setDarkMode,
            ),
      },
    );
  }
}