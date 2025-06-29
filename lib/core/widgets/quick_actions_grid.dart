// ===== شبكة الإجراءات السريعة =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'animated_button.dart';

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final String? title;

  const QuickActionsGrid({
    Key? key,
    required this.actions,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: Responsive.getPagePadding(context),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: Responsive.getPagePadding(context),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.getCrossAxisCount(
                context,
                mobile: 2,
                tablet: 3,
                desktop: 4,
              ),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _QuickActionCard(action: action);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: action.onTap,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              action.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              action.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}