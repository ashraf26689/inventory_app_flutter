// ===== بطاقة النشاط الحديث =====
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/transaction.dart';

class RecentActivityCard extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onViewAll;

  const RecentActivityCard({
    Key? key,
    required this.transactions,
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
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'النشاط الحديث',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('عرض الكل'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 48,
                        color: AppTheme.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد حركات حديثة',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.take(5).length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _ActivityItem(transaction: transaction);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Transaction transaction;

  const _ActivityItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.type == TransactionType.incoming;
    final statusType = isIncoming ? StatusType.success : StatusType.error;
    final statusText = isIncoming ? 'وارد' : 'صادر';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isIncoming ? AppTheme.successColor : AppTheme.errorColor)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncoming ? AppTheme.successColor : AppTheme.errorColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.itemName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${transaction.quantity} ${transaction.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusChip(
              label: statusText,
              type: statusType,
              showIcon: false,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}