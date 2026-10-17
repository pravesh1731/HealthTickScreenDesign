import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/providers.dart';
import 'journey_state.dart';

/// App-wide owner of the journey, shared by the Today and Journey screens.
/// Not autoDispose, so it keeps listening for changes while a lesson is open.
final journeyProvider = NotifierProvider<JourneyNotifier, JourneyState>(JourneyNotifier.new);

class JourneyNotifier extends Notifier<JourneyState> {
  @override
  JourneyState build() {
    // Real time: reload whenever the server says the journey changed.
    final changes = ref.watch(watchJourneyChangesProvider)().listen((_) => load());
    ref.onDispose(changes.cancel);

    // State can't change while build() runs, so the first load starts right after.
    Future.microtask(load);
    return const JourneyState(isLoading: true);
  }

  /// Loads the journey. On failure the previous journey (if any) stays on
  /// screen and [JourneyState.failure] says what went wrong.
  Future<void> load() async {
    final previous = state.journey;
    state = JourneyState(journey: previous, isLoading: true);

    final result = await ref.read(getJourneyProvider)();
    if (!ref.mounted) return;
    state = result.fold(
      onSuccess: (journey) => JourneyState(journey: journey),
      onFailure: (failure) => JourneyState(journey: previous, failure: failure),
    );
  }
}
