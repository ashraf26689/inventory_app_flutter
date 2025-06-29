// ===== بطاقة الصنف المحسنة =====
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusType = _getStatusType();
    final statusText = _getStatusText();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedButton(
        onPressed: onTap,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.code,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: statusText,
                    type: statusType,
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.grey600,
                      size: 20,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('تعديل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                            const SizedBox(width: 8),
                            const Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label: item.categoryDisplayName,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.straighten_outlined,
                    label: '${item.quantity} ${item.unitDisplayName}',
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.warning_amber_outlined,
                    label: 'حد أدنى: ${item.minQuantity}',
                    color: AppTheme.warningColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  StatusType _getStatusType() {
    if (item.isOutOfStock) return StatusType.error;
    if (item.isLowStock) return StatusType.warning;
    return StatusType.success;
  }

  String _getStatusText() {
    if (item.isOutOfStock) return 'نفذ المخزون';
    if (item.isLowStock) return 'مخزون منخفض';
    return 'متوفر';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}