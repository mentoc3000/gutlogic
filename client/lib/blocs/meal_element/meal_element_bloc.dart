import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/meal_element_repository.dart';
import '../bloc_helpers.dart';
import 'meal_element_event.dart';
import 'meal_element_state.dart';

class MealElementBloc extends Bloc<MealElementEvent, MealElementState> with StreamSubscriber {
  final MealElementRepository mealElementRepository;

  MealElementBloc({@required this.mealElementRepository});

  factory MealElementBloc.fromContext(BuildContext context) => MealElementBloc(
        mealElementRepository: context.repository<MealElementRepository>(),
      );

  @override
  Stream<Transition<MealElementEvent, MealElementState>> transformEvents(
    Stream<MealElementEvent> events,
    TransitionFunction<MealElementEvent, MealElementState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  MealElementState get initialState => MealElementLoading();

  @override
  Stream<MealElementState> mapEventToState(
    MealElementEvent event,
  ) async* {
    try {
      if (event is Load) {
        final mealElement = event.mealElement;
        yield MealElementLoaded(mealElement: mealElement);
      }
      if (event is StreamMealElement) {
        add(Load(event.mealElement));
        streamSubscription = mealElementRepository.stream(event.mealElement).listen(
              (mealElement) => add(Load(mealElement)),
              onError: (error, StackTrace trace) => add(Throw(error: error, trace: trace)),
            );
      }
      if (event is Delete) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.delete(mealElement));
      }
      if (event is Update) {
        unawaited(mealElementRepository.update(event.mealElement));
      }
      if (event is UpdateFoodReference) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.updateFoodReference(mealElement, event.foodReference));
      }
      if (event is UpdateQuantity) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.updateQuantity(mealElement, event.quantity));
      }
      if (event is UpdateNotes) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.updateNotes(mealElement, event.notes));
      }
      if (event is Throw) {
        yield MealElementError.fromError(error: event.error, trace: event.trace);
      }
    } catch (error, trace) {
      yield MealElementError.fromError(error: error, trace: trace);
    }
  }
}
