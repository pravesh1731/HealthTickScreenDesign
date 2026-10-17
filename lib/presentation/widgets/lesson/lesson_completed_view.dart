import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/lesson.dart';
import '../common/primary_button.dart';

/// "Awesome 🥳 – Health Points Earned: +7". When the day has another
/// lesson it starts automatically after a short countdown.
class LessonCompletedView extends StatefulWidget {
  const LessonCompletedView({
    super.key,
    required this.completion,
    required this.hasNextLesson,
    required this.onNext,
    required this.onFinish,
  });

  static const autoAdvanceSeconds = 5;

  final LessonCompletion completion;
  final bool hasNextLesson;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  State<LessonCompletedView> createState() => _LessonCompletedViewState();
}

class _LessonCompletedViewState extends State<LessonCompletedView> {
  Timer? _timer;
  int _secondsLeft = LessonCompletedView.autoAdvanceSeconds;

  @override
  void initState() {
    super.initState();
    if (widget.hasNextLesson) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 1) {
          _go();
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  void _go() {
    _timer?.cancel();
    widget.hasNextLesson ? widget.onNext() : widget.onFinish();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completion = widget.completion;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          const Text('✨👍', style: TextStyle(fontSize: 90)),
          const SizedBox(height: 28),
          const Text('Awesome 🥳', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Health Points Earned:  ',
                children: [
                  TextSpan(
                    text: '+${completion.pointsEarned}',
                    style: const TextStyle(color: AppColors.healthGreen, fontSize: 24),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19),
            ),
          ),
          if (!completion.firstCompletion) ...[
            const SizedBox(height: 12),
            const Text(
              "You've already earned points for this lesson. Practice makes perfect!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
          const Spacer(),
          PrimaryButton(
            label: widget.hasNextLesson ? 'Next Section' : 'Back to Journey',
            subtitle: widget.hasNextLesson
                ? '(Starting next section in $_secondsLeft seconds)'
                : null,
            onPressed: _go,
          ),
        ],
      ),
    );
  }
}
