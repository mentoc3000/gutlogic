import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/symptom_type.dart';
import '../../resources/symptom_type_repository.dart';
import '../bloc_helpers.dart';
import 'symptom_type_event.dart';
import 'symptom_type_state.dart';

class SymptomTypeBloc extends Bloc<SymptomTypeEvent, SymptomTypeState>
    with StreamSubscriber<BuiltList<SymptomType>, SymptomTypeState> {
  final SymptomTypeRepository repository;

  SymptomTypeBloc({required this.repository}) : super(SymptomTypesLoading()) {
    on<StreamAllSymptomTypes>(_onStreamAll);
    on<StreamSymptomTypeQuery>(_onStreamQuery);
    on<FetchAllSymptomTypes>(_onFetchAll);
    on<FetchSymptomTypeQuery>(_onFetchQuery);
    on<LoadSymptomTypes>((event, emit) => emit(SymptomTypesLoaded(event.items)));
    on<ThrowSymptomTypeError>((event, emit) => emit(SymptomTypeError.fromReport(event.report)));
  }

  static SymptomTypeBloc fromContext(BuildContext context) {
    return SymptomTypeBloc(repository: context.read<SymptomTypeRepository>());
  }

  Future<void> _onStreamAll(StreamAllSymptomTypes event, Emitter<SymptomTypeState> emit) async {
    try {
      add(const StreamSymptomTypeQuery(''));
    } catch (error, trace) {
      emit(SymptomTypeError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onStreamQuery(StreamSymptomTypeQuery event, Emitter<SymptomTypeState> emit) async {
    try {
      emit(SymptomTypesLoading());
      await streamSubscription?.cancel();
      streamSubscription = repository.streamQuery(event.query).listen(
        (symptomTypes) {
          add(LoadSymptomTypes(symptomTypes));
        },
        onError: (dynamic error, StackTrace trace) {
          add(ThrowSymptomTypeError.fromError(error: error, trace: trace));
        },
      );
    } catch (error, trace) {
      emit(SymptomTypeError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onFetchAll(FetchAllSymptomTypes event, Emitter<SymptomTypeState> emit) async {
    try {
      emit(SymptomTypesLoading());
      final items = await repository.fetchQuery('');
      emit(SymptomTypesLoaded(items));
    } catch (error, trace) {
      emit(SymptomTypeError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onFetchQuery(FetchSymptomTypeQuery event, Emitter<SymptomTypeState> emit) async {
    try {
      emit(SymptomTypesLoading());
      final items = await repository.fetchQuery(event.query);
      emit(SymptomTypesLoaded(items));
    } catch (error, trace) {
      emit(SymptomTypeError.fromError(error: error, trace: trace));
    }
  }
}
