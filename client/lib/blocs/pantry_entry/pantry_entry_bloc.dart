import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../models/preferences/preferences.dart';
import '../../resources/food/food_service.dart';
import '../../resources/pantry_service.dart';
import '../../resources/preferences_service.dart';
import '../bloc_helpers.dart';
import 'pantry_entry.dart';

class PantryEntryBloc extends Bloc<PantryEntryEvent, PantryEntryState> with StreamSubscriber<_Data?, PantryEntryState> {
  final PantryService repository;
  final FoodService foodService;
  final PreferencesService preferencesService;

  PantryEntryBloc({
    required this.repository,
    required this.foodService,
    required this.preferencesService,
    required String foodName,
  }) : super(PantryEntryLoading(foodName: foodName)) {
    on<CreateAndStreamEntry>(_onCreateAndStreamEntry);
    on<StreamEntry>(_onStreamEntry);
    on<Load>((event, emit) {
      emit(PantryEntryLoaded(
        pantryEntry: event.pantryEntry,
        food: event.food,
        excludedIrritants: preferencesService.value.irritantsExcluded ?? BuiltSet(),
      ));
    });
    on<Delete>(_onDelete);
    on<UpdateNotes>(_onUpdateNotes, transformer: debounceTransformer);
    on<UpdateSensitivityLevel>(_onUpdateSensitivityLevel, transformer: debounceTransformer);
    on<ThrowPantryEntryError>((event, emit) => emit(PantryEntryError.fromReport(event.report)));
  }

  static PantryEntryBloc fromContext(BuildContext context, {required String foodName}) {
    return PantryEntryBloc(
      repository: context.read<PantryService>(),
      foodService: context.read<FoodService>(),
      preferencesService: context.read<PreferencesService>(),
      foodName: foodName,
    );
  }

  Future<void> _onCreateAndStreamEntry(CreateAndStreamEntry event, Emitter<PantryEntryState> emit) async {
    try {
      final pantryEntry = await repository.addFood(event.foodReference).first;
      if (pantryEntry != null) {
        add(StreamEntry(pantryEntry));
      } else {
        emit(PantryEntryError(message: 'Failed to create pantry entry'));
      }
    } catch (error, trace) {
      emit(PantryEntryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onStreamEntry(StreamEntry event, Emitter<PantryEntryState> emit) async {
    try {
      emit(PantryEntryLoading(foodName: event.pantryEntry.foodReference.name));

      final food = await _pantryEntryFood(event.pantryEntry);

      emit(PantryEntryLoaded(
        pantryEntry: event.pantryEntry,
        food: food,
        excludedIrritants: preferencesService.value.irritantsExcluded ?? BuiltSet(),
      ));

      final pantryEntryStream = repository.stream(event.pantryEntry);
      final preferencesStream = preferencesService.stream;
      final dataStream = CombineLatestStream.combine2(pantryEntryStream, preferencesStream, _Data.combine);
      streamSubscription = dataStream.listen(
        (data) {
          add(Load(
            pantryEntry: data.pantryEntry!,
            food: food,
            excludedIrritants: data.preferences.irritantsExcluded ?? BuiltSet(),
          ));
        },
        onError: (dynamic error, StackTrace trace) {
          add(ThrowPantryEntryError.fromError(error: error, trace: trace));
        },
      );
    } catch (error, trace) {
      emit(PantryEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onDelete(Delete event, Emitter<PantryEntryState> emit) {
    try {
      if (state is PantryEntryLoaded) {
        unawaited(repository.delete((state as PantryEntryLoaded).pantryEntry));
      }
    } catch (error, trace) {
      emit(PantryEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateNotes(UpdateNotes event, Emitter<PantryEntryState> emit) {
    try {
      final pantryEntry = (state as PantryEntryLoaded).pantryEntry;
      unawaited(repository.updateNotes(pantryEntry, event.notes));
    } catch (error, trace) {
      emit(PantryEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateSensitivityLevel(UpdateSensitivityLevel event, Emitter<PantryEntryState> emit) {
    try {
      final pantryEntry = (state as PantryEntryLoaded).pantryEntry;
      unawaited(repository.updateSensitivityLevel(pantryEntry, event.sensitivityLevel));
    } catch (error, trace) {
      emit(PantryEntryError.fromError(error: error, trace: trace));
    }
  }

  FutureOr<Food?> _pantryEntryFood(PantryEntry pantryEntry) {
    if (pantryEntry.foodReference is EdamamFoodReference) {
      return foodService.streamFood(pantryEntry.foodReference as EdamamFoodReference).first;
    } else {
      return null;
    }
  }
}

class _Data {
  final PantryEntry? pantryEntry;
  final Preferences preferences;

  _Data({
    required this.pantryEntry,
    required this.preferences,
  });

  factory _Data.combine(PantryEntry? pantryEntry, Preferences preferences) =>
      _Data(pantryEntry: pantryEntry, preferences: preferences);
}
