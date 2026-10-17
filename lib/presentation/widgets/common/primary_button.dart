import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The chunky black call-to-action used at the bottom of lesson pages.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: subtitle == null ? 60 : 68,
          decoration: BoxDecoration(
            color: enabled ? AppColors.ink : const Color(0xFF5A5A5A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0xFF3A3A3A), offset: Offset(0, 5))],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
        ),
      ),
    );
  }
}
