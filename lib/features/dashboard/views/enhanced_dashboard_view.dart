// ===== لوحة التحكم المحسنة =====
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/notification_badge.dart';
import '../../../core/widgets/quick_actions_grid.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../../core/utils/responsive.dart';
import '../../../services/database_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/stock_alerts_card.dart';
import '../widgets/analytics_chart_card.dart';

class EnhancedDashboardView extends StatefulWidget {
  const EnhancedDashboardView({Key? key}) : super(key: key);

  @override
  State<EnhancedDashboardView> createState() => _EnhancedDashboardViewState();
}

class _EnhancedDashboardViewState extends State<EnhancedDashboardView> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _databaseService.getDashboardStats();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: CustomAppBar(
        title: 'لوحة التحكم',
        subtitle: 'نظرة عامة على المخزون',
        actions: [
          NotificationBadge(
            count: _dashboardData['lowStockItems'] ?? 0,
            child: IconButton(
              onPressed: () {
                // Navigate to notifications
              },
              icon: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Stats Cards
                    _buildStatsSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    _buildQuickActionsSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Analytics and Alerts
                    _buildAnalyticsSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Activity
                    _buildRecentActivitySection(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {
        'title': 'إجمالي الأصناف',
        'value': (_dashboardData['totalItems'] ?? 0).toString(),
        'subtitle': 'صنف مسجل',
        'icon': Icons.inventory_2_outlined,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'إجمالي الكمية',
        'value': (_dashboardData['totalQuantity'] ?? 0).toStringAsFixed(0),
        'subtitle': 'وحدة في المخزون',
        'icon': Icons.analytics_outlined,
        'color': AppTheme.successColor,
      },
      {
        'title': 'مخزون منخفض',
        'value': (_dashboardData['lowStockItems'] ?? 0).toString(),
        'subtitle': 'صنف يحتاج تجديد',
        'icon': Icons.warning_amber_outlined,
        'color': AppTheme.warningColor,
      },
      {
        'title': 'الفئات',
        'value': (_dashboardData['categories'] ?? 0).toString(),
        'subtitle': 'فئة مختلفة',
        'icon': Icons.category_outlined,
        'color': AppTheme.infoColor,
      },
    ];

    return Padding(
      padding: Responsive.getPagePadding(context),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return AnimatedListItem(
            index: index,
            child: DashboardCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              subtitle: stat['subtitle'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              onTap: () {
                // Navigate to relevant section
                if (index == 0 || index == 2) {
                  Navigator.pushNamed(context, '/items');
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      QuickAction(
        title: 'إضافة صنف',
        subtitle: 'صنف جديد للمخزون',
        icon: Icons.add_box_outlined,
        color: AppTheme.successColor,
        onTap: () => Navigator.pushNamed(context, '/items'),
      ),
      QuickAction(
        title: 'حركة جديدة',
        subtitle: 'تسجيل حركة مخزون',
        icon: Icons.swap_horiz_outlined,
        color: AppTheme.primaryColor,
        onTap: () => Navigator.pushNamed(context, '/transactions'),
      ),
      QuickAction(
        title: 'التقارير',
        subtitle: 'عرض التقارير',
        icon: Icons.assessment_outlined,
        color: AppTheme.infoColor,
        onTap: () => Navigator.pushNamed(context, '/reports'),
      ),
      QuickAction(
        title: 'المستخدمين',
        subtitle: 'إدارة المستخدمين',
        icon: Icons.people_outlined,
        color: AppTheme.secondaryColor,
        onTap: () => Navigator.pushNamed(context, '/users'),
      ),
    ];

    return QuickActionsGrid(
      title: 'الإجراءات السريعة',
      actions: actions,
    );
  }

  Widget _buildAnalyticsSection() {
    return Padding(
      padding: Responsive.getPagePadding(context),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AnimatedListItem(
              index: 0,
              child: AnalyticsChartCard(
                title: 'اتجاه المخزون',
                data: _dashboardData,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedListItem(
              index: 1,
              child: StockAlertsCard(
                lowStockItems: _dashboardData['lowStockItems'] ?? 0,
                onViewAll: () => Navigator.pushNamed(context, '/items'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Padding(
      padding: Responsive.getPagePadding(context),
      child: AnimatedListItem(
        index: 0,
        child: RecentActivityCard(
          transactions: _dashboardData['recentTransactions'] ?? [],
          onViewAll: () => Navigator.pushNamed(context, '/transactions'),
        ),
      ),
    );
  }
}