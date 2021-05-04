import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../resources/diary_repositories/bowel_movement_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'bowel_movement_entry_event.dart';
import 'bowel_movement_entry_state.dart';

class BowelMovementEntryBloc extends Bloc<BowelMovementEntryEvent, BowelMovementEntryState>
    with StreamSubscriber, DiaryEntryMapper {
  final BowelMovementEntryRepository repository;

  BowelMovementEntryBloc({required this.repository}) : super(BowelMovementEntryLoading()) {
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
              (d) => add(LoadBowelMovementEntry(d as BowelMovementEntry)),
              onError: (error, StackTrace trace) =>
                  add(ThrowBowelMovementEntryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is LoadBowelMovementEntry) {
        yield BowelMovementEntryLoaded(event.diaryEntry);
      }
      if (event is CreateAndStreamDiaryEntry) {
        final bowelMovementEntry = await repository.create();
        if (bowelMovementEntry != null) {
          add(StreamBowelMovementEntry(bowelMovementEntry));
        } else {
          yield BowelMovementEntryError(message: 'Faild to create bowel movement entry');
        }
      }
      if (event is UpdateType) {
        final bowelMovementEntry = (state as DiaryEntryLoaded).diaryEntry as BowelMovementEntry;
        unawaited(repository.updateType(bowelMovementEntry, event.type));
      }
      if (event is UpdateVolume) {
        final bowelMovementEntry = (state as DiaryEntryLoaded).diaryEntry as BowelMovementEntry;
        unawaited(repository.updateVolume(bowelMovementEntry, event.volume));
      }
      yield* mapDiaryEntryEventToState(event);
      if (event is ThrowBowelMovementEntryError) {
        yield BowelMovementEntryError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield BowelMovementEntryError.fromError(error: error, trace: trace);
    }
  }
}
