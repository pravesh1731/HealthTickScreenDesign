import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/journey.dart';
import '../providers/journey/journey_notifier.dart';
import '../providers/journey/journey_state.dart';
import '../widgets/common/app_snack_bar.dart';
import '../widgets/common/failure_view.dart';
import '../widgets/journey/checkpoint_gate.dart';
import '../widgets/journey/day_lessons_card.dart';
import '../widgets/journey/journey_section.dart';
import '../widgets/journey/status_banner.dart';
import 'lesson_player_page.dart';

class JourneyPage extends ConsumerStatefulWidget {
  const JourneyPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const JourneyPage());

  @override
  ConsumerState<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends ConsumerState<JourneyPage> {
  static const _maxContentWidth = 520.0;

  final _anchors = <String, NodeAnchor>{};
  final _contentKey = GlobalKey();
  final _popover = OverlayPortalController();

  String? _selectedDayId;
  double _selectedNodeX = 0;

  NodeAnchor _anchorFor(String dayId) => _anchors.putIfAbsent(dayId, NodeAnchor.new);

  JourneyNotifier get _journey => ref.read(journeyProvider.notifier);

  @override
  Widget build(BuildContext context) {
    ref.listen(journeyProvider, _onStateChanged);
    final state = ref.watch(journeyProvider);
    final journey = state.journey;

    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: const Text('Your Journey')),
      body: journey == null
          ? _buildLoadingOrError(state)
          : OverlayPortal(
              controller: _popover,
              overlayChildBuilder: (context) => _buildPopover(context, journey),
              child: _buildMap(journey),
            ),
    );
  }

  Widget _buildLoadingOrError(JourneyState state) {
    final failure = state.failure;
    return failure == null
        ? const Center(child: CircularProgressIndicator(color: AppColors.ink))
        : FailureView(failure: failure, onRetry: _journey.load);
  }

  Widget _buildMap(Journey journey) {
    if (journey.statuses.isEmpty) {
      return const Center(
        child: Text(
          'Your journey is being prepared.\nPlease check back soon.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: _journey.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12),
        child: Center(
          child: ConstrainedBox(
            key: _contentKey,
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              children: [
                for (final (index, status) in journey.statuses.indexed) ...[
                  StatusBanner(status: status),
                  JourneySection(
                    status: status,
                    exitReached: _nextStatusStarted(journey, index),
                    anchorFor: _anchorFor,
                    onDayTap: _onDayTap,
                  ),
                  if (index < journey.statuses.length - 1) const CheckpointGate(),
                ],
                // Room for the popover of the last circles to scroll into view.
                const SizedBox(height: 380),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// True when the status after [index] has an unlocked first circle.
  static bool _nextStatusStarted(Journey journey, int index) {
    if (index + 1 >= journey.statuses.length) return false;
    final nextDays = journey.statuses[index + 1].days;
    return nextDays.isNotEmpty && !nextDays.first.isLocked;
  }

  Widget _buildPopover(BuildContext context, Journey journey) {
    final dayId = _selectedDayId;
    final day = dayId == null ? null : journey.dayById(dayId);
    final contentBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (day == null || contentBox == null || !contentBox.hasSize) {
      return const SizedBox.shrink();
    }

    final contentLeft = contentBox.localToGlobal(Offset.zero).dx;
    final cardWidth = contentBox.size.width - 32;
    final cardCenterX = contentLeft + contentBox.size.width / 2;
    final dx = cardCenterX - _selectedNodeX;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _closePopover),
        ),
        Positioned(
          left: 0,
          top: 0,
          width: cardWidth,
          child: CompositedTransformFollower(
            link: _anchorFor(day.id).link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: Offset(dx, 6),
            child: DayLessonsCard(
              day: day,
              pointerX: (cardWidth / 2 - dx).clamp(28, cardWidth - 28),
              onClose: _closePopover,
              onLessonTap: (lesson) => _onLessonTap(day, lesson),
            ),
          ),
        ),
      ],
    );
  }

  void _onStateChanged(JourneyState? previous, JourneyState state) {
    // A circle can disappear when the backend lowers the circle count.
    final selected = _selectedDayId;
    if (selected != null && state.journey?.dayById(selected) == null) _closePopover();

    // A reload failed while a journey is already on screen: keep showing it
    // and offer a retry.
    final failure = state.failure;
    if (failure != null && previous?.failure == null && state.journey != null) {
      showFailureSnackBar(context, failure, onRetry: _journey.load);
    }
  }

  void _onDayTap(JourneyDay day) {
    if (_selectedDayId == day.id) return _closePopover();
    final nodeContext = _anchorFor(day.id).key.currentContext;
    final box = nodeContext?.findRenderObject() as RenderBox?;
    if (nodeContext == null || box == null) return;

    setState(() {
      _selectedDayId = day.id;
      _selectedNodeX = box.localToGlobal(box.size.center(Offset.zero)).dx;
    });
    _popover.show();
    Scrollable.ensureVisible(
      nodeContext,
      alignment: 0.1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _closePopover() {
    if (_popover.isShowing) _popover.hide();
    if (_selectedDayId != null && mounted) setState(() => _selectedDayId = null);
  }

  Future<void> _onLessonTap(JourneyDay day, LessonSummary lesson) async {
    if (day.isLocked || !lesson.canOpen) {
      showAppSnackBar(
        context,
        icon: Icons.lock_rounded,
        message: day.isLocked
            ? 'Day ${day.dayNumber} is locked. Finish the earlier days first.'
            : 'Finish the previous lesson to unlock this one.',
      );
      return;
    }
    _closePopover();
    await Navigator.of(context).push(LessonPlayerPage.route(lessonId: lesson.id));
    // Live updates usually beat us to it; this covers a dropped socket.
    if (mounted) _journey.load();
  }
}
