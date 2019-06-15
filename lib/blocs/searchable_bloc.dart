import 'package:meta/meta.dart';
import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:bloc/bloc.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';
import 'searchable_state.dart';
import 'searchable_event.dart';

abstract class SearchableBloc<
    T extends Searchable,
    R extends SearchableRepository,
    E extends SearchableEvent,
    S extends SearchableState> extends Bloc<E, S> {
  @protected
  final R repository;

  SearchableBloc(this.repository);

  @override
  S get initialState => SearchableLoading() as S;

  @override
  Stream<S> mapEventToState(
    SearchableEvent event,
  ) async* {
    if (event is FetchAll) {
      try {
        yield SearchableLoading() as S;
        BuiltList<T> items = await repository.fetchAll();
        yield SearchableLoaded<T>(items) as S;
      } catch (_) {
        yield SearchableError() as S;
      }
    }
    if (event is FetchQuery) {
      try {
        yield SearchableLoading() as S;
        BuiltList<T> items = await repository.fetchQuery(event.query);
        yield SearchableLoaded<T>(items) as S;
      } catch (_) {
        yield SearchableError() as S;
      }
    }
  }
}
