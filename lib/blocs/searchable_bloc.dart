import 'package:meta/meta.dart';
import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:bloc/bloc.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';
import 'searchable_state.dart';
import 'searchable_event.dart';

abstract class SearchableBloc<T extends Searchable,
        R extends SearchableRepository>
    extends Bloc<SearchableEvent, SearchableState> {
  @protected
  final R repository;

  SearchableBloc(this.repository);

  @override
  SearchableState get initialState => SearchableLoading();

  @override
  Stream<SearchableState> mapEventToState(
    SearchableEvent event,
  ) async* {
    if (event is FetchAll) {
      try {
        BuiltList<T> items = await repository.fetchAll();
        yield SearchableLoaded(items);
      } catch (_) {
        yield SearchableError();
      }
    }
    if (event is FetchQuery) {
      try {
        BuiltList<T> items = await repository.fetchQuery(event.query);
        yield SearchableLoaded(items);
      } catch (_) {
        yield SearchableError();
      }
    }
  }
}
