import 'package:flutter/material.dart';

import '../../../core/error/failures.dart';
import 'failure_copy.dart';

/// Dark floating message used across the app ("Hello! Please select an
/// answer..."). Replaces any snackbar already showing so they never queue up.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  String? title,
  IconData icon = Icons.info_rounded,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}

void showFailureSnackBar(BuildContext context, Failure failure, {VoidCallback? onRetry}) {
  showAppSnackBar(
    context,
    title: failure.title,
    message: failure.message,
    icon: failure.icon,
    actionLabel: failure.isRetryable && onRetry != null ? 'Retry' : null,
    onAction: onRetry,
  );
}
