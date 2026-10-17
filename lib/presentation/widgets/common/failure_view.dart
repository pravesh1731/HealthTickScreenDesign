import 'package:flutter/material.dart';

import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import 'failure_copy.dart';

/// Full-area error state with a retry button when retrying makes sense.
class FailureView extends StatelessWidget {
  const FailureView({
    super.key,
    required this.failure,
    this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final canRetry = onRetry != null && failure.isRetryable;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
              child: Icon(failure.icon, size: 40, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text(
              failure.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (canRetry)
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            if (secondaryLabel != null && onSecondary != null)
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
          ],
        ),
      ),
    );
  }
}
