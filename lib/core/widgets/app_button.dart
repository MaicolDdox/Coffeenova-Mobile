import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? background;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        minimumSize: const Size.fromHeight(48),
      ),
      onPressed: loading ? null : onPressed,
      child: child,
    );
  }
}
