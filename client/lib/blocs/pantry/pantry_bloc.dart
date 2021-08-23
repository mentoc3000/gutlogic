import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/pantry_service.dart';
import '../bloc_helpers.dart';
import 'pantry_event.dart';
import 'pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> with StreamSubscriber {
  final PantryService pantryService;

  PantryBloc({required this.pantryService}) : super(PantryLoading());

  factory PantryBloc.fromContext(BuildContext context) {
    return PantryBloc(pantryService: context.read<PantryService>());
  }

  @override
  Stream<Transition<PantryEvent, PantryState>> transformEvents(
    Stream<PantryEvent> events,
    TransitionFunction<PantryEvent, PantryState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<PantryState> mapEventToState(PantryEvent event) async* {
    try {
      if (event is StreamAllPantry) {
        yield PantryLoading();
        await streamSubscription?.cancel();
        streamSubscription = pantryService.streamAll().listen(
              (pantryEntries) => add(LoadPantry(items: pantryEntries)),
              onError: (error, StackTrace trace) => add(ThrowPantryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is StreamPantryQuery) {
        yield PantryLoading();
        await streamSubscription?.cancel();
        streamSubscription = pantryService.streamQuery(event.query).listen(
              (pantryEntries) => add(LoadPantry(items: pantryEntries)),
              onError: (error, StackTrace trace) => add(ThrowPantryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is LoadPantry) {
        yield PantryLoaded(event.items);
      }
      if (event is DeletePantryEntry) {
        await pantryService.delete(event.pantryEntry);
        yield PantryEntryDeleted(event.pantryEntry);
      }
      if (event is UndeletePantryEntry) {
        unawaited(pantryService.add(event.pantryEntry));
      }
      if (event is ThrowPantryError) {
        yield PantryError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield PantryError.fromError(error: error, trace: trace);
    }
  }
}
