import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/resources/preferences_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../models/meal_element.dart';
import '../../models/preferences/preferences.dart';
import '../../resources/diary_repositories/meal_element_repository.dart';
import '../../resources/food/food_service.dart';
import '../bloc_helpers.dart';
import 'meal_element_event.dart';
import 'meal_element_state.dart';

class MealElementBloc extends Bloc<MealElementEvent, MealElementState> with StreamSubscriber<_Data, MealElementState> {
  final MealElementRepository mealElementRepository;
  final FoodService foodService;
  final PreferencesService preferencesService;

  MealElementBloc({
    required this.mealElementRepository,
    required this.foodService,
    required this.preferencesService,
  }) : super(MealElementLoading()) {
    on<StreamMealElement>(_onStreamMealElement);
    on<Load>((event, emit) {
      emit(MealElementLoaded(
        mealElement: event.mealElement,
        food: event.food,
        excludedIrritants: event.excludedIrritants,
      ));
    });
    on<Delete>(_onDelete);
    on<Update>(_onUpdate, transformer: debounceTransformer);
    on<UpdateQuantity>(_onUpdateQuantity, transformer: debounceTransformer);
    on<UpdateNotes>(_onUpdateNotes, transformer: debounceTransformer);
    on<ThrowMealElementError>((event, emit) => emit(MealElementError.fromReport(event.report)));
  }

  static MealElementBloc fromContext(BuildContext context) {
    return MealElementBloc(
      mealElementRepository: context.read<MealElementRepository>(),
      foodService: context.read<FoodService>(),
      preferencesService: context.read<PreferencesService>(),
    );
  }

  Future<void> _onStreamMealElement(StreamMealElement event, Emitter<MealElementState> emit) async {
    try {
      var mealElement = event.mealElement;
      Food? food;

      // If the meal element uses an Edamam food, fetch that food to get the measure options
      if (mealElement.foodReference is EdamamFoodReference) {
        emit(MealElementLoading());
        food = await foodService.streamFood(mealElement.foodReference).first;

        // If the meal element doesn't have a measure yet, set it to the first option
        if (mealElement.quantity?.measure == null && (food?.measures.isNotEmpty ?? false)) {
          mealElement = mealElement.rebuild((b) => b..quantity.measure = food!.measures.first.toBuilder());
          add(Update(mealElement));
        }
      }

      final preferences = preferencesService.value;

      emit(MealElementLoaded(
        mealElement: mealElement,
        food: food,
        excludedIrritants: preferences.irritantsExcluded ?? BuiltSet(),
      ));

      // Subscribe to the stream, updating the mealElement but using the same food value, which cannot change.
      final mealElementStream = mealElementRepository.stream(mealElement);
      final preferencesStream = preferencesService.stream;
      final dataStream = CombineLatestStream.combine2(mealElementStream, preferencesStream, _Data.combine);
      streamSubscription = dataStream.listen(
        (data) {
          add(Load(
            mealElement: data.mealElement!,
            food: food,
            excludedIrritants: data.preferences.irritantsExcluded ?? BuiltSet(),
          ));
        },
        onError: (dynamic error, StackTrace trace) {
          add(ThrowMealElementError.fromError(error: error, trace: trace));
        },
      );
    } catch (error, trace) {
      emit(MealElementError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onDelete(Delete event, Emitter<MealElementState> emit) async {
    try {
      final mealElement = (state as MealElementLoaded).mealElement;
      unawaited(mealElementRepository.delete(mealElement));
    } catch (error, trace) {
      emit(MealElementError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdate(Update event, Emitter<MealElementState> emit) {
    try {
      unawaited(mealElementRepository.update(event.mealElement));
    } catch (error, trace) {
      emit(MealElementError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<MealElementState> emit) {
    try {
      final mealElement = (state as MealElementLoaded).mealElement;
      unawaited(mealElementRepository.updateQuantity(mealElement, event.quantity));
    } catch (error, trace) {
      emit(MealElementError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateNotes(UpdateNotes event, Emitter<MealElementState> emit) {
    try {
      final mealElement = (state as MealElementLoaded).mealElement;
      unawaited(mealElementRepository.updateNotes(mealElement, event.notes));
    } catch (error, trace) {
      emit(MealElementError.fromError(error: error, trace: trace));
    }
  }
}

class _Data {
  final MealElement? mealElement;
  final Preferences preferences;

  _Data({
    required this.mealElement,
    required this.preferences,
  });

  factory _Data.combine(MealElement? mealElement, Preferences preferences) =>
      _Data(mealElement: mealElement, preferences: preferences);
}
