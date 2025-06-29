import 'package:flutter/material.dart';
import '../constants/app_texts.dart';
import '../constants/app_colors.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  const AppDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ===== Header مع تصميم محسن =====
            Container(
              height: isSmallScreen ? 140 : 160,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: AppColors.cardShadow,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.textInverse.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: AppColors.textInverse,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic
                                      ? AppTexts.appTitle
                                      : AppTexts.appTitleEn,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? 'نظام إدارة المخزون'
                                      : 'Inventory System',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textInverse
                                            .withOpacity(0.8),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== قائمة العناصر =====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: isArabic ? AppTexts.dashboard : AppTexts.dashboardEn,
                    subtitle:
                        isArabic ? 'لوحة التحكم الرئيسية' : 'Main Dashboard',
                    route: '/dashboard',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2,
                    title: isArabic ? AppTexts.inventory : AppTexts.inventoryEn,
                    subtitle: isArabic ? 'إدارة الأصناف' : 'Manage Items',
                    route: '/items',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.swap_horiz_outlined,
                    activeIcon: Icons.swap_horiz,
                    title: isArabic
                        ? AppTexts.transactions
                        : AppTexts.transactionsEn,
                    subtitle:
                        isArabic ? 'إدارة الحركات' : 'Manage Transactions',
                    route: '/transactions',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.assessment_outlined,
                    activeIcon: Icons.assessment,
                    title: isArabic ? AppTexts.reports : AppTexts.reportsEn,
                    subtitle: isArabic
                        ? 'التقارير والإحصائيات'
                        : 'Reports & Analytics',
                    route: '/reports',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    title: isArabic ? AppTexts.users : AppTexts.usersEn,
                    subtitle: isArabic ? 'إدارة المستخدمين' : 'Manage Users',
                    route: '/users',
                  ),
                ],
              ),
            ),

            const Divider(height: 32, thickness: 1),

            // ===== أزرار إضافية =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: isArabic ? AppTexts.settings : AppTexts.settingsEn,
                    subtitle: isArabic ? 'إعدادات النظام' : 'System Settings',
                    route: '/settings',
                  ),
                  const SizedBox(height: 8),
                  _drawerItem(
                    context,
                    icon: Icons.logout_outlined,
                    activeIcon: Icons.logout,
                    title: isArabic ? AppTexts.logout : AppTexts.logoutEn,
                    subtitle: isArabic ? 'تسجيل الخروج' : 'Sign Out',
                    route: '/login',
                    logout: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== معلومات إضافية =====
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Column(
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
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? 'معلومات النظام' : 'System Info',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic ? 'الإصدار: 1.0.0' : 'Version: 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String subtitle,
    required String route,
    bool logout = false,
  }) {
    final selected =
        ModalRoute.of(context)?.settings.name == route || currentRoute == route;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color:
            selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: selected
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.textLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            selected ? activeIcon : icon,
            color: selected ? AppColors.textInverse : AppColors.textLight,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.textDark,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected
                    ? AppColors.primary.withOpacity(0.7)
                    : AppColors.textLight,
              ),
        ),
        trailing: selected
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textInverse,
                  size: 12,
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          if (logout) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else if (!selected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
