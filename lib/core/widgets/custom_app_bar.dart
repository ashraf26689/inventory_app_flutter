// ===== شريط التطبيق المخصص =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showShadow;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: centerTitle 
                      ? CrossAxisAlignment.center 
                      : CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grey900,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 80 : 64);
}