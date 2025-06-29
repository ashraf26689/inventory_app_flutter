// ===== شارة الإشعارات =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final bool showZero;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.textColor,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0 || showZero)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? AppTheme.errorColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}