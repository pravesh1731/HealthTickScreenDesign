import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journey.dart';

/// The popover under a circle listing the day's lessons, with a pointer
/// aimed at the circle it belongs to.
class DayLessonsCard extends StatelessWidget {
  const DayLessonsCard({
    super.key,
    required this.day,
    required this.pointerX,
    required this.onClose,
    required this.onLessonTap,
  });

  final JourneyDay day;

  /// Horizontal position of the pointer, relative to the card's left edge.
  final double pointerX;
  final VoidCallback onClose;
  final ValueChanged<LessonSummary> onLessonTap;

  static const _pointerSize = 16.0;
  static const _background = Color(0xFFE2E2E2);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: pointerX - _pointerSize),
              child: CustomPaint(
                size: const Size(_pointerSize * 2, _pointerSize),
                painter: _PointerPainter(_background),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(day: day, onClose: onClose),
                if (day.lessons.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Today's lessons are being prepared. Check back soon!",
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                for (final lesson in day.lessons)
                  _LessonRow(
                    lesson: lesson,
                    dayLocked: day.isLocked,
                    onTap: () => onLessonTap(lesson),
                  ),
                const SizedBox(height: 16),
                _PrimaryAction(day: day, onLessonTap: onLessonTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.day, required this.onClose});

  final JourneyDay day;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final summary = day.isLocked
        ? 'Locked'
        : '${day.completedLessons}/${day.lessons.length} completed';
    return Row(
      children: [
        Expanded(
          child: Text(
            'DAY ${day.dayNumber}  ·  $summary',
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: onClose,
          icon: const Icon(Icons.cancel_outlined, size: 30),
        ),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.dayLocked, required this.onTap});

  final LessonSummary lesson;
  final bool dayLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (lesson.state) {
      LessonState.completed => (Icons.check_rounded, AppColors.checkGreen),
      LessonState.available => (Icons.description_outlined, AppColors.ink),
      LessonState.locked => (Icons.lock_rounded, AppColors.healthGreen),
    };
    final dimmed = dayLocked || lesson.state == LessonState.locked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: dimmed ? AppColors.faint : color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                lesson.title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  color: dimmed ? AppColors.faint : AppColors.ink,
                  fontWeight: lesson.state == LessonState.available
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.day, required this.onLessonTap});

  final JourneyDay day;
  final ValueChanged<LessonSummary> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final lesson = day.lessonToPlay;
    final label = switch (day.state) {
      DayState.locked => 'LOCKED',
      DayState.completed => 'DO IT AGAIN',
      DayState.inProgress when day.lessons.isEmpty => 'COMING SOON',
      DayState.inProgress => day.completedLessons == 0 ? 'START' : 'CONTINUE',
    };

    return Column(
      children: [
        SizedBox(
          width: 240,
          height: 54,
          child: FilledButton(
            onPressed: lesson == null ? null : () => onLessonTap(lesson),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              disabledBackgroundColor: const Color(0xFFBDBDBD),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
        ),
        if (day.isLocked || day.isCompleted) ...[
          const SizedBox(height: 10),
          Text(
            day.isLocked ? 'Complete the earlier days to unlock' : 'Completed',
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
        ],
      ],
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) => oldDelegate.color != color;
}
