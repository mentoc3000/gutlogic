import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../models/diary_entry/symptom_entry.dart';
import '../../resources/diary_repositories/symptom_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'symptom_entry_event.dart';
import 'symptom_entry_state.dart';

class SymptomEntryBloc extends Bloc<SymptomEntryEvent, SymptomEntryState> with StreamSubscriber, DiaryEntryMapper {
  final SymptomEntryRepository repository;

  SymptomEntryBloc({required this.repository}) : super(SymptomEntryLoading()) {
    diaryEntryStreamer = repository;
    diaryEntryDeleter = repository;
    diaryEntryUpdater = repository;
  }

  factory SymptomEntryBloc.fromContext(BuildContext context) {
    return SymptomEntryBloc(repository: context.read<SymptomEntryRepository>());
  }

  @override
  Stream<Transition<SymptomEntryEvent, SymptomEntryState>> transformEvents(
    Stream<SymptomEntryEvent> events,
    TransitionFunction<SymptomEntryEvent, SymptomEntryState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<SymptomEntryState> mapEventToState(SymptomEntryEvent event) async* {
    try {
      if (event is StreamSymptomEntry) {
        yield SymptomEntryLoaded(event.diaryEntry);
        streamSubscription = diaryEntryStreamer.stream(event.diaryEntry).listen(
              (d) => add(LoadSymptomEntry(d as SymptomEntry)),
              onError: (error, StackTrace trace) => add(ThrowSymptomEntryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is LoadSymptomEntry) {
        yield SymptomEntryLoaded(event.diaryEntry);
      }
      if (event is CreateFromAndStreamSymptomEntry) {
        final symptomEntry = await repository.createFrom(event.symptomType);
        if (symptomEntry != null) {
          add(StreamSymptomEntry(symptomEntry));
        } else {
          yield SymptomEntryError(message: 'Failed to create symptom entry');
        }
      }
      if (event is UpdateSymptom) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
        unawaited(repository.updateSymptom(diaryEntry, event.symptom));
      }
      if (event is UpdateSymptomType) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
        unawaited(repository.updateSymptomType(diaryEntry, event.symptomType));
      }
      if (event is UpdateSymptomName) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
        unawaited(repository.updateSymptomName(diaryEntry, event.symptomName));
      }
      if (event is UpdateSeverity) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
        unawaited(repository.updateSeverity(diaryEntry, event.severity));
      }
      yield* mapDiaryEntryEventToState(event);
      if (event is ThrowSymptomEntryError) {
        yield SymptomEntryError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield SymptomEntryError.fromError(error: error, trace: trace);
    }
  }
}
