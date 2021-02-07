import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/meal_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'meal_entry_event.dart';
import 'meal_entry_state.dart';

class MealEntryBloc extends Bloc<MealEntryEvent, MealEntryState> with StreamSubscriber, DiaryEntryMapper {
  final MealEntryRepository repository;

  MealEntryBloc({@required this.repository}) : super(MealEntryLoading()) {
    diaryEntryStreamer = repository;
    diaryEntryDeleter = repository;
    diaryEntryUpdater = repository;
  }

  factory MealEntryBloc.fromContext(BuildContext context) {
    return MealEntryBloc(repository: context.read<MealEntryRepository>());
  }

  @override
  Stream<Transition<MealEntryEvent, MealEntryState>> transformEvents(
    Stream<MealEntryEvent> events,
    TransitionFunction<MealEntryEvent, MealEntryState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<MealEntryState> mapEventToState(MealEntryEvent event) async* {
    try {
      if (event is StreamMealEntry) {
        yield MealEntryLoaded(event.diaryEntry);
        streamSubscription = diaryEntryStreamer.stream(event.diaryEntry).listen(
              (d) => add(LoadMealEntry(d)),
              onError: (error, StackTrace trace) => add(ThrowMealEntryError(error: error, trace: trace)),
            );
      }
      if (event is LoadMealEntry) {
        yield MealEntryLoaded(event.diaryEntry);
      }
      if (event is CreateAndStreamDiaryEntry) {
        final mealEntry = await repository.create();
        add(StreamMealEntry(mealEntry));
      }
      if (event is AddMealElement) {
        final mealEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.createMealElement(mealEntry, event.food));
      }
      if (event is MoveMealElement) {
        final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
        unawaited(repository.reorderMealElement(diaryEntry, event.fromIndex, event.toIndex));
      }
      if (event is DeleteMealElement) {
        await repository.removeMealElement(event.mealEntry, event.mealElement);
        yield MealElementDeleted(mealEntry: event.mealEntry, mealElement: event.mealElement);
      }
      if (event is UndeleteMealElement) {
        unawaited(repository.addMealElement(event.mealEntry, event.mealElement));
      }
      yield* mapDiaryEntryEventToState(event);
    } catch (error, trace) {
      yield MealEntryError.fromError(error: error, trace: trace);
    }
  }
}
