import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/journey.dart';
import '../providers/journey/journey_notifier.dart';
import '../providers/journey/journey_state.dart';
import '../widgets/common/app_snack_bar.dart';
import '../widgets/common/failure_copy.dart';
import '../widgets/today/todays_task_card.dart';
import 'journey_page.dart';
import 'lesson_player_page.dart';

/// Home screen: stats, today's lessons and the entry point to the journey.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journeyProvider);
    final journey = state.journey;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.ink,
          onRefresh: ref.read(journeyProvider.notifier).load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            children: [
              const SizedBox(height: 36),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "today's task",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                  _JourneyLink(onTap: () => _openJourney(context)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTaskArea(context, ref, state, journey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskArea(BuildContext context, WidgetRef ref, JourneyState state, Journey? journey) {
    if (journey != null) {
      return TodaysTaskCard(
        journey: journey,
        onOpenJourney: () => _openJourney(context),
        onLessonTap: (lesson) => _openLesson(context, ref, lesson),
      );
    }
    final failure = state.failure;
    if (failure == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    // Compact inline error: the rest of the home screen stays usable.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(failure.icon, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(failure.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(failure.message, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          if (failure.isRetryable)
            TextButton(
              onPressed: ref.read(journeyProvider.notifier).load,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  void _openJourney(BuildContext context) => Navigator.of(context).push(JourneyPage.route());

  Future<void> _openLesson(BuildContext context, WidgetRef ref, LessonSummary lesson) async {
    if (!lesson.canOpen) {
      showAppSnackBar(
        context,
        icon: Icons.lock_rounded,
        message: 'Finish the previous lesson to unlock this one.',
      );
      return;
    }
    final journey = ref.read(journeyProvider.notifier);
    await Navigator.of(context).push(LessonPlayerPage.route(lessonId: lesson.id));
    await journey.load();
  }
}

class _JourneyLink extends StatelessWidget {
  const _JourneyLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.ink, width: 1.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('JOURNEY', style: TextStyle(fontSize: 17, letterSpacing: 1.2)),
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
