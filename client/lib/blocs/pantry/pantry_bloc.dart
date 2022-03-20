import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/pantry_service.dart';
import '../bloc_helpers.dart';
import 'pantry_event.dart';
import 'pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> with StreamSubscriber {
  final PantryService pantryService;

  PantryBloc({required this.pantryService}) : super(PantryLoading()) {
    on<StreamAllPantry>(_onStreamAll);
    on<StreamPantryQuery>(_onStreamQuery);
    on<LoadPantry>((event, emit) => emit(PantryLoaded(event.items)));
    on<DeletePantryEntry>(_onDelete);
    on<UndeletePantryEntry>(_onUndelete);
    on<ThrowPantryError>((event, emit) => emit(PantryError.fromReport(event.report)));
  }

  static PantryBloc fromContext(BuildContext context) {
    return PantryBloc(pantryService: context.read<PantryService>());
  }

  Future<void> _onStreamAll(StreamAllPantry event, Emitter<PantryState> emit) async {
    try {
      emit(PantryLoading());
      await streamSubscription?.cancel();
      streamSubscription = pantryService.streamAll().listen(
            (pantryEntries) => add(LoadPantry(items: pantryEntries)),
            onError: (error, StackTrace trace) => add(ThrowPantryError.fromError(error: error, trace: trace)),
          );
    } catch (error, trace) {
      emit(PantryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onStreamQuery(StreamPantryQuery event, Emitter<PantryState> emit) async {
    try {
      emit(PantryLoading());
      await streamSubscription?.cancel();
      streamSubscription = pantryService.streamQuery(event.query).listen(
            (pantryEntries) => add(LoadPantry(items: pantryEntries)),
            onError: (error, StackTrace trace) => add(ThrowPantryError.fromError(error: error, trace: trace)),
          );
    } catch (error, trace) {
      emit(PantryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onDelete(DeletePantryEntry event, Emitter<PantryState> emit) async {
    try {
      await pantryService.delete(event.pantryEntry);
      emit(PantryEntryDeleted(event.pantryEntry));
    } catch (error, trace) {
      emit(PantryError.fromError(error: error, trace: trace));
    }
  }

  void _onUndelete(UndeletePantryEntry event, Emitter<PantryState> emit) {
    try {
      unawaited(pantryService.add(event.pantryEntry));
    } catch (error, trace) {
      emit(PantryError.fromError(error: error, trace: trace));
    }
  }
}
