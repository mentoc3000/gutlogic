import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../resources/food/food_service.dart';
import '../../resources/pantry_service.dart';
import '../bloc_helpers.dart';
import 'pantry_entry.dart';

class PantryEntryBloc extends Bloc<PantryEntryEvent, PantryEntryState> with StreamSubscriber {
  final PantryService repository;
  final FoodService foodService;

  PantryEntryBloc({required this.repository, required this.foodService}) : super(PantryEntryLoading());

  factory PantryEntryBloc.fromContext(BuildContext context) {
    return PantryEntryBloc(repository: context.read<PantryService>(), foodService: context.read<FoodService>());
  }

  @override
  Stream<Transition<PantryEntryEvent, PantryEntryState>> transformEvents(
    Stream<PantryEntryEvent> events,
    TransitionFunction<PantryEntryEvent, PantryEntryState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<PantryEntryState> mapEventToState(PantryEntryEvent event) async* {
    try {
      if (event is CreateAndStreamEntry) {
        final pantryEntry = await repository.addFood(event.foodReference).first;
        if (pantryEntry != null) {
          add(StreamEntry(pantryEntry));
        } else {
          yield PantryEntryError(message: 'Failed to create pantry entry');
        }
      }
      if (event is StreamEntry) {
        yield PantryEntryLoading();

        final food = await _pantryEntryFood(event.pantryEntry);

        yield PantryEntryLoaded(pantryEntry: event.pantryEntry, food: food);

        streamSubscription = repository.stream(event.pantryEntry).listen(
              (pantryEntry) => add(Load(pantryEntry: pantryEntry!, food: food)),
              onError: (error, StackTrace trace) => add(ThrowPantryEntryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is Load) {
        yield PantryEntryLoaded(pantryEntry: event.pantryEntry, food: event.food);
      }
      if (event is Delete) {
        if (state is PantryEntryLoaded) {
          unawaited(repository.delete((state as PantryEntryLoaded).pantryEntry));
        }
      }
      if (event is UpdateNotes) {
        final pantryEntry = (state as PantryEntryLoaded).pantryEntry;
        unawaited(repository.updateNotes(pantryEntry, event.notes));
      }
      if (event is UpdateSensitivityLevel) {
        final pantryEntry = (state as PantryEntryLoaded).pantryEntry;
        unawaited(repository.updateSensitivityLevel(pantryEntry, event.sensitivityLevel));
      }
      if (event is ThrowPantryEntryError) {
        yield PantryEntryError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield PantryEntryError.fromError(error: error, trace: trace);
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
