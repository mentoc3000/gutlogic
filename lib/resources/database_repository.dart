import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';
import 'searchable_repository.dart';

abstract class DatabaseRepository<T extends DatabaseItem>
    extends SearchableRepository<T> {
  // BuiltList<T> items;

  DatabaseRepository();

// TODO: throw error if duplicate id
  void insert(T item) async => items = items.rebuild((b) => b..add(item));

  void insertAll(Iterable<T> items) async => items.map(this.insert);

  void delete(String id) async =>
      items = items.rebuild((b) => b..removeWhere((i) => i.id == id));

  void upsert(T item) async => items = items.rebuild((b) => b
    ..removeWhere((i) => i.id == item.id)
    ..add(item));
}
