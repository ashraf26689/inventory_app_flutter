// ===== شريحة الحالة المحسنة =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;

  const StatusChip({
    Key? key,
    required this.label,
    required this.type,
    this.icon,
    this.showIcon = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final chipIcon = icon ?? _getDefaultIcon();

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors['border']!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && chipIcon != null) ...[
            Icon(
              chipIcon,
              size: 14,
              color: colors['foreground'],
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: colors['foreground'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case StatusType.success:
        return {
          'background': AppTheme.successColor.withOpacity(0.1),
          'foreground': AppTheme.successColor,
          'border': AppTheme.successColor.withOpacity(0.3),
        };
      case StatusType.warning:
        return {
          'background': AppTheme.warningColor.withOpacity(0.1),
          'foreground': AppTheme.warningColor,
          'border': AppTheme.warningColor.withOpacity(0.3),
        };
      case StatusType.error:
        return {
          'background': AppTheme.errorColor.withOpacity(0.1),
          'foreground': AppTheme.errorColor,
          'border': AppTheme.errorColor.withOpacity(0.3),
        };
      case StatusType.info:
        return {
          'background': AppTheme.infoColor.withOpacity(0.1),
          'foreground': AppTheme.infoColor,
          'border': AppTheme.infoColor.withOpacity(0.3),
        };
      case StatusType.neutral:
        return {
          'background': AppTheme.grey200,
          'foreground': AppTheme.grey700,
          'border': AppTheme.grey300,
        };
    }
  }

  IconData? _getDefaultIcon() {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle_outline;
      case StatusType.warning:
        return Icons.warning_amber_outlined;
      case StatusType.error:
        return Icons.error_outline;
      case StatusType.info:
        return Icons.info_outline;
      case StatusType.neutral:
        return Icons.circle_outlined;
    }
  }
}