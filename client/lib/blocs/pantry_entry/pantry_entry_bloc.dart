import 'package:pedantic/pedantic.dart';
import 'package:bloc/bloc.dart';
import '../../resources/pantry_repository.dart';
import '../bloc_helpers.dart';
import 'pantry_entry.dart';

class PantryEntryBloc extends Bloc<PantryEntryEvent, PantryEntryState> with StreamSubscriber {
  final PantryRepository repository;

  PantryEntryBloc({required this.repository}) : super(PantryEntryLoading());

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
        final pantryEntry = await repository.addFood(event.foodReference);
        if (pantryEntry != null) {
          add(StreamEntry(pantryEntry));
        } else {
          yield PantryEntryError(message: 'Failed to create pantry entry');
        }
      }
      if (event is StreamEntry) {
        yield PantryEntryLoaded(event.pantryEntry);
        streamSubscription = repository.stream(event.pantryEntry).listen(
              (pantryEntry) => add(Load(pantryEntry!)),
              onError: (error, StackTrace trace) => add(ThrowPantryEntryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is StreamId) {
        yield PantryEntryLoading();
        streamSubscription = repository.streamId(event.id).listen(
              (pantryEntry) => add(Load(pantryEntry!)),
              onError: (error, StackTrace trace) => add(ThrowPantryEntryError.fromError(error: error, trace: trace)),
            );
      }
      if (event is Load) {
        yield PantryEntryLoaded(event.pantryEntry);
      }
      if (event is Delete) {
        if (state is PantryEntryLoaded) {
          unawaited(repository.delete((state as PantryEntryLoaded).pantryEntry));
        }
      }
      if (event is UpdateEntry) {
        unawaited(repository.updateEntry(event.pantryEntry));
      }
      if (event is UpdateNotes) {
        final pantryEntry = (state as PantryEntryLoaded).pantryEntry;
        unawaited(repository.updateNotes(pantryEntry, event.notes));
      }
      if (event is UpdateSensitivity) {
        final pantryEntry = (state as PantryEntryLoaded).pantryEntry;
        unawaited(repository.updateSensitivity(pantryEntry, event.sensitivity));
      }
      if (event is ThrowPantryEntryError) {
        yield PantryEntryError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield PantryEntryError.fromError(error: error, trace: trace);
    }
  }
}
