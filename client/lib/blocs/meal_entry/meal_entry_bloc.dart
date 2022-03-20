import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../models/diary_entry/meal_entry.dart';
import '../../resources/diary_repositories/meal_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'meal_entry_event.dart';
import 'meal_entry_state.dart';

class MealEntryBloc extends Bloc<MealEntryEvent, MealEntryState> with StreamSubscriber, DiaryEntryMapper {
  final MealEntryRepository repository;

  MealEntryBloc({required this.repository}) : super(MealEntryLoading()) {
    timelineRepository = repository;

    on<StreamMealEntry>(_onStream);
    on<LoadMealEntry>((event, emit) => emit(MealEntryLoaded(event.diaryEntry)));
    on<CreateAndStreamMealEntry>(_onCreateAndStream);
    on<AddMealElement>(_onAdd);
    on<MoveMealElement>(_onMove);
    on<DeleteMealElement>(_onDeleteMealElement);
    on<UndeleteMealElement>(_onUndeleteMealElement);
    on<UpdateMealEntry>(onUpdateEntry, transformer: debounceTransformer);
    on<UpdateMealEntryDateTime>(onUpdateDateTime, transformer: debounceTransformer);
    on<UpdateMealEntryNotes>(onUpdateNotes, transformer: debounceTransformer);
    on<DeleteMealEntry>(onDeleteEntry);
    on<ThrowMealEntryError>((event, emit) => emit(MealEntryError.fromReport(event.report)));
  }

  static MealEntryBloc fromContext(BuildContext context) {
    return MealEntryBloc(repository: context.read<MealEntryRepository>());
  }

  void _onStream(StreamMealEntry event, Emitter<MealEntryState> emit) {
    try {
      emit(MealEntryLoaded(event.diaryEntry));
      streamSubscription = timelineRepository.stream(event.diaryEntry).listen(
            (d) => add(LoadMealEntry(d as MealEntry)),
            onError: (error, StackTrace trace) => add(ThrowMealEntryError.fromError(error: error, trace: trace)),
          );
    } catch (error, trace) {
      emit(MealEntryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onCreateAndStream(CreateAndStreamMealEntry event, Emitter<MealEntryState> emit) async {
    try {
      final mealEntry = await repository.create();
      if (mealEntry != null) {
        add(StreamMealEntry(mealEntry));
      } else {
        emit(MealEntryError(message: 'Failed to create meal entry'));
      }
    } catch (error, trace) {
      emit(MealEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onAdd(AddMealElement event, Emitter<MealEntryState> emit) {
    try {
      final mealEntry = (state as DiaryEntryLoaded).diaryEntry as MealEntry;
      unawaited(repository.createMealElement(mealEntry, event.food));
    } catch (error, trace) {
      emit(MealEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onMove(MoveMealElement event, Emitter<MealEntryState> emit) {
    try {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as MealEntry;
      unawaited(repository.reorderMealElement(diaryEntry, event.fromIndex, event.toIndex));
    } catch (error, trace) {
      emit(MealEntryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onDeleteMealElement(DeleteMealElement event, Emitter<MealEntryState> emit) async {
    try {
      await repository.removeMealElement(event.mealEntry, event.mealElement);
      emit(MealElementDeleted(mealEntry: event.mealEntry, mealElement: event.mealElement));
    } catch (error, trace) {
      emit(MealEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUndeleteMealElement(UndeleteMealElement event, Emitter<MealEntryState> emit) {
    try {
      unawaited(repository.addMealElement(event.mealEntry, event.mealElement));
    } catch (error, trace) {
      emit(MealEntryError.fromError(error: error, trace: trace));
    }
  }
}
