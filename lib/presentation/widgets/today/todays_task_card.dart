import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journey.dart';

/// Lists the lessons of the current day, as on the app's home screen.
class TodaysTaskCard extends StatelessWidget {
  const TodaysTaskCard({
    super.key,
    required this.journey,
    required this.onLessonTap,
    required this.onOpenJourney,
  });

  final Journey journey;
  final ValueChanged<LessonSummary> onLessonTap;
  final VoidCallback onOpenJourney;

  @override
  Widget build(BuildContext context) {
    final day = journey.currentDay;

    if (day == null) {
      return _MessageCard(
        icon: Icons.lock_clock_rounded,
        message: 'Your first day unlocks soon!',
        onTap: onOpenJourney,
      );
    }
    if (journey.isUnlockedJourneyComplete) {
      return _MessageCard(
        icon: Icons.description_outlined,
        message: 'You have completed your journey!',
        onTap: onOpenJourney,
      );
    }

    return _Frame(
      child: Column(
        children: [
          for (final (index, lesson) in day.lessons.indexed) ...[
            if (index > 0) const SizedBox(height: 4),
            _LessonTile(lesson: lesson, onTap: () => onLessonTap(lesson)),
          ],
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.onTap});

  final LessonSummary lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = lesson.state == LessonState.completed;
    final current = lesson.state == LessonState.available;
    final (icon, color) = switch (lesson.state) {
      LessonState.completed => (Icons.check_rounded, AppColors.checkGreen),
      LessonState.available => (Icons.description_outlined, AppColors.ink),
      LessonState.locked => (Icons.lock_rounded, AppColors.healthGreen),
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE6E6E6),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                lesson.title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w400,
                  color: current ? AppColors.ink : AppColors.muted,
                  decoration: completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: current ? AppColors.ink : AppColors.faint),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.message, required this.onTap});

  final IconData icon;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _Frame(
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE6E6E6),
              child: Icon(icon, color: AppColors.ink, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 30),
          ],
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: child,
    );
  }
}
