import 'package:meta/meta.dart';
import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:bloc/bloc.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';
import 'searchable_bloc.dart';
import 'database_state.dart';
import 'database_event.dart';

abstract class DatabaseBloc<T extends DatabaseItem,
    R extends DatabaseRepository> extends Bloc<DatabaseEvent, DatabaseState> {
  @protected
  final R repository;

  DatabaseBloc(this.repository);

  @override
  DatabaseState get initialState => DatabaseLoading();

  @override
  Stream<DatabaseState> mapEventToState(
    DatabaseEvent event,
  ) async* {
    if (event is FetchAll) {
      try {
        yield DatabaseLoading();
        BuiltList<T> items = await repository.fetchAll();
        yield DatabaseLoaded<T>(items);
      } catch (_) {
        yield DatabaseError();
      }
    }
    if (event is FetchQuery) {
      try {
        yield DatabaseLoading();
        BuiltList<T> items = await repository.fetchQuery(event.query);
        yield DatabaseLoaded<T>(items);
      } catch (_) {
        yield DatabaseError();
      }
    }
    if (event is Insert) {
      try {
        repository.insert(event.item);
      } catch (_) {
        yield DatabaseError();
      }
    }
    if (event is Delete) {
      try {
        repository.delete(event.id);
      } catch (_) {
        yield DatabaseError();
      }
    }
    if (event is Upsert) {
      try {
        repository.upsert(event.item);
      } catch (_) {
        yield DatabaseError();
      }
    }
  }
}
