import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journey.dart';

/// Icons the backend may name for a status. Unknown names fall back to a
/// flag, so a new name on the server never breaks the banner.
const _statusIcons = <String, IconData>{
  'eco': Icons.eco_rounded,
  'insights': Icons.insights_rounded,
  'psychology': Icons.psychology_rounded,
  'emoji_events': Icons.emoji_events_rounded,
  'star': Icons.star_rounded,
};

IconData statusIcon(String name) => _statusIcons[name] ?? Icons.flag_rounded;

/// The "Status / Beginner / LEVEL-1" card that opens each section.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.status});

  final JourneyStatus status;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(status.colorHex);
    final edge = Color.lerp(color, Colors.black, 0.12)!;
    final iconColor = Color.lerp(color, Colors.black, 0.55)!;

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: edge, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon(status.icon), size: 46, color: iconColor),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status', style: TextStyle(fontSize: 15, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Text(
                    status.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'LEVEL-${status.level}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  if (status.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      status.subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (status.isUnlocked) return card;
    return Stack(
      children: [
        Opacity(opacity: 0.55, child: card),
        const Positioned(
          top: 12,
          right: 30,
          child: Chip(
            avatar: Icon(Icons.lock_rounded, size: 16),
            label: Text('Locked'),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
