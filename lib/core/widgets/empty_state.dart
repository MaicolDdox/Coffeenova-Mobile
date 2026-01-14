import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.coffee_outlined, color: AppColors.color4, size: 52),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (message != null) ...[
          const SizedBox(height: 4),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.color4),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 12),
          action!,
        ]
      ],
    );
  }
}
