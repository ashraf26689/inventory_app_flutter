import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import 'constants/app_texts.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'views/auth/login_view.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/items/item_list_view.dart';
import 'views/transactions/transaction_list_view.dart';
import 'views/reports/reports_view.dart';
import 'views/users/users_view.dart';
import 'views/settings/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      title: AppTexts.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,

        // ===== أزرار مرتفعة (Elevated Buttons) =====
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.textInverse,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // مستديرة
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ===== أزرار محيطية (Outlined Buttons) =====
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.buttonSecondary,
            side: BorderSide(color: AppColors.buttonSecondary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ===== أزرار نصية (Text Buttons) =====
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // ===== حقول الإدخال (Input Fields) =====
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14,
          ),
        ),

        // ===== شريط التطبيق (App Bar) =====
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ptSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),

        // ===== الخطوط (Typography) =====
        textTheme:
            GoogleFonts.ptSansTextTheme(Theme.of(context).textTheme).copyWith(
          // العناوين الرئيسية (20-28px)
          headlineLarge: GoogleFonts.ptSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          headlineMedium: GoogleFonts.ptSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          headlineSmall: GoogleFonts.ptSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),

          // العناوين الفرعية (16-20px)
          titleLarge: GoogleFonts.ptSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          titleMedium: GoogleFonts.ptSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          titleSmall: GoogleFonts.ptSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),

          // النص الأساسي (14-16px)
          bodyLarge: GoogleFonts.ptSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark,
          ),
          bodyMedium: GoogleFonts.ptSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark,
          ),

          // النص الثانوي (12-14px)
          bodySmall: GoogleFonts.ptSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
          ),
          labelLarge: GoogleFonts.ptSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),

        // ===== ألوان إضافية =====
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.textInverse,
          onSecondary: AppColors.textInverse,
          onSurface: AppColors.textDark,
          onBackground: AppColors.textDark,
          onError: AppColors.textInverse,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.ptSansTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
      ),
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
        '/dashboard': (context) => const DashboardView(),
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

// ===== صفحة مؤقتة للصفحات غير المطورة بعد =====
class _ComingSoonView extends StatelessWidget {
  final String title;

  const _ComingSoonView({required this.title});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Icon(
                    Icons.construction,
                    size: 64,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  isArabic ? 'قريباً...' : 'Coming Soon...',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isArabic
                      ? 'هذه الصفحة قيد التطوير وسيتم إطلاقها قريباً'
                      : 'This page is under development and will be launched soon',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isArabic ? 'العودة' : 'Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
