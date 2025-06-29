import 'package:flutter/material.dart';
import '../../constants/app_texts.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_drawer.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textDark),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(AppTexts.dashboard),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: إضافة الإشعارات
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: إضافة الإعدادات
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== عنوان الترحيب =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                ),
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
                            Icons.dashboard,
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
                                'مرحباً بك في نظام إدارة المخزون',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.textInverse,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'نظرة عامة على حالة المخزون والحركات',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
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
              const SizedBox(height: 32),

              // ===== إحصائيات سريعة =====
              Text(
                'الإحصائيات السريعة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 20),

              // ===== بطاقات الإحصائيات =====
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: isSmallScreen ? 1.1 : 1.3,
                children: [
                  _StatCard(
                    title: AppTexts.totalItems,
                    value: '120',
                    subtitle: 'أصناف',
                    icon: Icons.inventory_2,
                    gradient: AppColors.primaryGradient,
                  ),
                  _StatCard(
                    title: AppTexts.totalQuantity,
                    value: '3,500',
                    subtitle: 'وحدة',
                    icon: Icons.analytics,
                    gradient: AppColors.successGradient,
                  ),
                  _StatCard(
                    title: AppTexts.lowStockItems,
                    value: '5',
                    subtitle: 'أصناف',
                    icon: Icons.warning,
                    gradient: AppColors.warningGradient,
                  ),
                  _StatCard(
                    title: AppTexts.categories,
                    value: '6',
                    subtitle: 'فئات',
                    icon: Icons.category,
                    gradient: AppColors.secondaryGradient,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ===== الرسوم البيانية =====
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'تحليل المخزون',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===== بطاقة الرسوم البيانية =====
              Card(
                elevation: 4,
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أفضل 5 أصناف حسب الاستخدام',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // رسم بياني شريطي بسيط
                      _BarChart(),

                      const SizedBox(height: 24),

                      // رسم بياني دائري بسيط
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'توزيع المخزون',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _PieChart(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _ChartLegend(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ===== قسم آخر الحركات =====
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppTexts.recentTransactions,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===== بطاقة آخر الحركات =====
              Card(
                elevation: 4,
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _TransactionItem(
                        itemName: 'كابل شبكة CAT6',
                        type: 'وارد',
                        quantity: '50',
                        date: '2024-01-15',
                        typeColor: AppColors.incoming,
                      ),
                      const Divider(height: 32),
                      _TransactionItem(
                        itemName: 'محول كهربائي',
                        type: 'صادر',
                        quantity: '10',
                        date: '2024-01-14',
                        typeColor: AppColors.outgoing,
                      ),
                      const Divider(height: 32),
                      _TransactionItem(
                        itemName: 'بطارية ليثيوم',
                        type: 'استهلاك',
                        quantity: '5',
                        date: '2024-01-13',
                        typeColor: AppColors.consumption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ===== قسم الإجراءات السريعة =====
              Text(
                'الإجراءات السريعة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 20),

              // ===== أزرار الإجراءات السريعة =====
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isSmallScreen ? 2 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.5,
                children: [
                  _ActionButton(
                    title: 'إضافة صنف',
                    subtitle: 'إضافة صنف جديد',
                    icon: Icons.add_box,
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pushNamed(context, '/items');
                    },
                  ),
                  _ActionButton(
                    title: 'حركة جديدة',
                    subtitle: 'تسجيل حركة',
                    icon: Icons.swap_horiz,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, '/transactions');
                    },
                  ),
                  _ActionButton(
                    title: 'التقارير',
                    subtitle: 'عرض التقارير',
                    icon: Icons.assessment,
                    color: AppColors.info,
                    onTap: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== بطاقة الإحصائيات =====
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
          gradient: gradient,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textInverse.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.textInverse,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textInverse,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textInverse.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInverse.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ===== رسم بياني شريطي بسيط =====
class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BarItem(label: 'كابلات', value: 0.8, color: AppColors.primary),
          _BarItem(label: 'محولات', value: 0.6, color: AppColors.success),
          _BarItem(label: 'بطاريات', value: 0.4, color: AppColors.warning),
          _BarItem(label: 'أجهزة', value: 0.7, color: AppColors.info),
          _BarItem(label: 'أخرى', value: 0.3, color: AppColors.secondary),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _BarItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 160 * value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

// ===== رسم بياني دائري بسيط =====
class _PieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // دائرة خلفية
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 8),
            ),
          ),
          // شرائح الدائرة
          CustomPaint(
            size: const Size(120, 120),
            painter: PieChartPainter(),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 8;

    double startAngle = 0;
    final data = [
      {'color': AppColors.primary, 'value': 0.4},
      {'color': AppColors.success, 'value': 0.3},
      {'color': AppColors.warning, 'value': 0.2},
      {'color': AppColors.info, 'value': 0.1},
    ];

    for (var item in data) {
      paint.color = item['color'] as Color;
      final sweepAngle = 2 * 3.14159 * (item['value'] as double);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== مفتاح الرسم البياني =====
class _ChartLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التوزيع',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: 16),
        _LegendItem(label: 'كابلات (40%)', color: AppColors.primary),
        const SizedBox(height: 8),
        _LegendItem(label: 'محولات (30%)', color: AppColors.success),
        const SizedBox(height: 8),
        _LegendItem(label: 'بطاريات (20%)', color: AppColors.warning),
        const SizedBox(height: 8),
        _LegendItem(label: 'أجهزة (10%)', color: AppColors.info),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
      ],
    );
  }
}

// ===== عنصر الحركة =====
class _TransactionItem extends StatelessWidget {
  final String itemName;
  final String type;
  final String quantity;
  final String date;
  final Color typeColor;

  const _TransactionItem({
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.date,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            type == 'وارد'
                ? Icons.arrow_downward
                : type == 'صادر'
                    ? Icons.arrow_upward
                    : Icons.remove,
            color: typeColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quantity,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===== زر الإجراء =====
class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
