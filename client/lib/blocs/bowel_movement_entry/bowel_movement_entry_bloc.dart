import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/bowel_movement_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'bowel_movement_entry_event.dart';
import 'bowel_movement_entry_state.dart';

class BowelMovementEntryBloc extends Bloc<BowelMovementEntryEvent, BowelMovementEntryState>
    with StreamSubscriber, DiaryEntryMapper {
  final BowelMovementEntryRepository repository;

  BowelMovementEntryBloc({@required this.repository}) : super(BowelMovementEntryLoading()) {
    diaryEntryStreamer = repository;
    diaryEntryDeleter = repository;
    diaryEntryUpdater = repository;
  }

  factory BowelMovementEntryBloc.fromContext(BuildContext context) {
    return BowelMovementEntryBloc(repository: context.read<BowelMovementEntryRepository>());
  }

  @override
  Stream<Transition<BowelMovementEntryEvent, BowelMovementEntryState>> transformEvents(
    Stream<BowelMovementEntryEvent> events,
    TransitionFunction<BowelMovementEntryEvent, BowelMovementEntryState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<BowelMovementEntryState> mapEventToState(BowelMovementEntryEvent event) async* {
    try {
      if (event is StreamBowelMovementEntry) {
        yield BowelMovementEntryLoaded(event.diaryEntry);
        streamSubscription = diaryEntryStreamer.stream(event.diaryEntry).listen(
              (d) => add(LoadBowelMovementEntry(d)),
              onError: (error, StackTrace trace) => add(ThrowBowelMovementEntryError(error: error, trace: trace)),
            );
      }
      if (event is LoadBowelMovementEntry) {
        yield BowelMovementEntryLoaded(event.diaryEntry);
      }
      if (event is CreateAndStreamDiaryEntry) {
        final bowelMovementEntry = await repository.create();
        add(StreamBowelMovementEntry(bowelMovementEntry));
      }
      if (event is UpdateType) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.updateType(diaryEntry, event.type));
      }
      if (event is UpdateVolume) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.updateVolume(diaryEntry, event.volume));
      }
      yield* mapDiaryEntryEventToState(event);
    } catch (error, trace) {
      yield BowelMovementEntryError.fromError(error: error, trace: trace);
    }
  }
}
