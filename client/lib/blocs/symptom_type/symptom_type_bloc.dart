import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../resources/symptom_type_repository.dart';
import '../bloc_helpers.dart';
import 'symptom_type_event.dart';
import 'symptom_type_state.dart';

class SymptomTypeBloc extends Bloc<SymptomTypeEvent, SymptomTypeState> with StreamSubscriber {
  final SymptomTypeRepository repository;

  SymptomTypeBloc({@required this.repository}) : super(SymptomTypesLoading());

  factory SymptomTypeBloc.fromContext(BuildContext context) => SymptomTypeBloc(
        repository: context.repository<SymptomTypeRepository>(),
      );

  @override
  Stream<SymptomTypeState> mapEventToState(SymptomTypeEvent event) async* {
    try {
      if (event is StreamAllSymptomTypes) {
        add(const StreamSymptomTypeQuery(''));
      }
      if (event is StreamSymptomTypeQuery) {
        yield SymptomTypesLoading();
        await streamSubscription?.cancel();
        streamSubscription = repository.streamQuery(event.query).listen(
              (symptomTypes) => add(LoadSymptomTypes(symptomTypes)),
              onError: (error, StackTrace trace) => add(ThrowSymptomTypeError(error: error, trace: trace)),
            );
      }
      if (event is ThrowSymptomTypeError) {
        yield SymptomTypeError.fromError(error: event.error, trace: event.trace);
      }
      if (event is FetchAllSymptomTypes) {
        // TODO: remove these loading pages? Or maybe only show them if the fetch takes a long time.
        // https://stackoverflow.com/questions/64885470/can-dart-streams-emit-a-value-if-the-stream-is-not-done-within-a-duration/64978139
        yield SymptomTypesLoading();
        final items = await repository.fetchQuery('');
        yield SymptomTypesLoaded(items);
      }
      if (event is FetchSymptomTypeQuery) {
        yield SymptomTypesLoading();
        final items = await repository.fetchQuery(event.query);
        yield SymptomTypesLoaded(items);
      }
      if (event is LoadSymptomTypes) {
        yield SymptomTypesLoaded(event.items);
      }
    } catch (error, trace) {
      yield SymptomTypeError.fromError(error: error, trace: trace);
    }
  }
}
