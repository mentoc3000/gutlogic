import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/symptom_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'symptom_entry_event.dart';
import 'symptom_entry_state.dart';

class SymptomEntryBloc extends Bloc<SymptomEntryEvent, SymptomEntryState> with StreamSubscriber, DiaryEntryMapper {
  final SymptomEntryRepository repository;

  SymptomEntryBloc({@required this.repository}) {
    diaryEntryStreamer = repository;
    diaryEntryDeleter = repository;
    diaryEntryUpdater = repository;
  }

  factory SymptomEntryBloc.fromContext(BuildContext context) => SymptomEntryBloc(
        repository: context.repository<SymptomEntryRepository>(),
      );

  @override
  SymptomEntryState get initialState => SymptomEntryLoading();

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
              (d) => add(LoadSymptomEntry(d)),
              onError: (error, StackTrace trace) => add(ThrowSymptomEntryError(error: error, trace: trace)),
            );
      }
      if (event is LoadSymptomEntry) {
        yield SymptomEntryLoaded(event.diaryEntry);
      }
      if (event is CreateFromAndStreamSymptomEntry) {
        final symptomEntry = await repository.createFrom(event.symptomType);
        add(StreamSymptomEntry(symptomEntry));
      }
      if (event is UpdateSymptom) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.updateSymptom(diaryEntry, event.symptom));
      }
      if (event is UpdateSymptomType) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.updateSymptomType(diaryEntry, event.symptomType));
      }
      if (event is UpdateSymptomName) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.updateSymptomName(diaryEntry, event.symptomName));
      }
      if (event is UpdateSeverity) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.updateSeverity(diaryEntry, event.severity));
      }
      yield* mapDiaryEntryEventToState(event);
    } catch (error, trace) {
      yield SymptomEntryError.fromError(error: error, trace: trace);
    }
  }
}
