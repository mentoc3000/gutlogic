import 'package:meta/meta.dart';
import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';

abstract class SearchableBloc<T extends Searchable,
    R extends SearchableRepository> {
  @protected
  final R repository;

  @protected
  final controller = StreamController<BuiltList<T>>.broadcast();

  Stream<BuiltList<T>> get all => controller.stream;

  SearchableBloc(this.repository);

  void fetchAll() async {
    BuiltList<T> items = await repository.fetchAll();
    controller.sink.add(items);
  }

  void fetchQuery(String query) async {
    BuiltList<T> items = await repository.fetchQuery(query);
    controller.sink.add(items);
  }

  dispose() {
    controller.close();
  }
}

abstract class DatabaseBloc<T extends DatabaseItem,
    R extends DatabaseRepository> extends SearchableBloc<T, R> {
  DatabaseBloc(R repository) : super(repository);

  void insert(T item) async => repository.insert(item);
  void insertAll(Iterable<T> items) async => repository.insertAll(items);
  void delete(String id) async => repository.delete(id);
  void upsert(T item) async => repository.upsert(item);
}
