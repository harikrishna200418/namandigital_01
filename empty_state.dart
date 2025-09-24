import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  const EmptyState({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: Icon(
                  actionText == 'Add Todo' ? Icons.add : Icons.refresh,
                ),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}