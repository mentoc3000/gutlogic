import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/pantry_repository.dart';
import '../bloc_helpers.dart';
import 'pantry_event.dart';
import 'pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> with StreamSubscriber {
  final PantryRepository repository;

  PantryBloc({required this.repository}) : super(PantryLoading());

  factory PantryBloc.fromContext(BuildContext context) {
    return PantryBloc(
      repository: context.read<PantryRepository>(),
    );
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
        streamSubscription = repository.streamAll().listen(
              (pantryEntries) => add(LoadPantry(items: pantryEntries)),
              onError: (error, StackTrace trace) => add(ThrowPantryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is StreamPantryQuery) {
        yield PantryLoading();
        await streamSubscription?.cancel();
        streamSubscription = repository.streamQuery(event.query).listen(
              (pantryEntries) => add(LoadPantry(items: pantryEntries)),
              onError: (error, StackTrace trace) => add(ThrowPantryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is LoadPantry) {
        yield PantryLoaded(event.items);
      }
      if (event is DeletePantryEntry) {
        await repository.delete(event.pantryEntry);
        yield PantryEntryDeleted(event.pantryEntry);
      }
      if (event is UndeletePantryEntry) {
        unawaited(repository.add(event.pantryEntry));
      }
      if (event is ThrowPantryError) {
        yield PantryError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield PantryError.fromError(error: error, trace: trace);
    }
  }
}
