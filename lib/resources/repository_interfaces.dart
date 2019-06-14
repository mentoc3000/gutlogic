import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

abstract class SearchableRepository<T extends Searchable> {
  BuiltList<T> items;

  Future<BuiltList<T>> fetchAll() async => items;

  Future<BuiltList<T>> fetchQuery(String query) async {
    if (query == '') {
      return items;
    }
    return items..where((f) => f.toString().contains(query));
  }
}

abstract class DatabaseRepository<T extends DatabaseItem>
    extends SearchableRepository<T> {
  BuiltList<T> items;

  DatabaseRepository();

// TODO: throw error if duplicate id
  void insert(T item) => items = items.rebuild((b) => b..add(item));

  void insertAll(Iterable<T> items) => items.map(this.insert);

  void delete(String id) =>
      items = items.rebuild((b) => b..removeWhere((i) => i.id == id));

  void upsert(T item) => items = items.rebuild((b) => b
    ..removeWhere((i) => i.id == item.id)
    ..add(item));
}
