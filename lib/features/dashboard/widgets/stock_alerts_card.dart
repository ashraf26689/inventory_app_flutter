// ===== بطاقة تنبيهات المخزون =====
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_button.dart';

class StockAlertsCard extends StatelessWidget {
  final int lowStockItems;
  final VoidCallback? onViewAll;

  const StockAlertsCard({
    Key? key,
    required this.lowStockItems,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تنبيهات المخزون',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lowStockItems > 0 
                    ? AppTheme.warningColor.withOpacity(0.1)
                    : AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lowStockItems > 0 
                      ? AppTheme.warningColor.withOpacity(0.3)
                      : AppTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    lowStockItems.toString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: lowStockItems > 0 
                          ? AppTheme.warningColor 
                          : AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lowStockItems > 0 
                        ? 'صنف يحتاج تجديد'
                        : 'جميع الأصناف متوفرة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: lowStockItems > 0 
                          ? AppTheme.warningColor 
                          : AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (lowStockItems > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  onPressed: onViewAll,
                  backgroundColor: AppTheme.warningColor,
                  child: const Text(
                    'عرض التفاصيل',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}