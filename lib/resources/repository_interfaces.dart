import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

abstract class SearchableRepository<T> {
  BuiltList<T> items;

  Future<BuiltList<T>> fetchAll() async => items;

  Future<BuiltList<T>> fetchQuery(String query) async {
    if (query == '') {
      return items;
    }
    return items..where((f) => f.toString().contains(query));
  }

}

abstract class DatabaseRepository extends SearchableRepository<DatabaseItem>{
  BuiltList<DatabaseItem> items;

  DatabaseRepository();

// TODO: throw error if duplicate id
  void insert(DatabaseItem item) => items = items.rebuild((b) => b..add(item));

  void insertAll(Iterable<DatabaseItem> items) => items.map(this.insert);

  void delete(String id) =>
      items = items.rebuild((b) => b..removeWhere((i) => i.id == id));

  void upsert(DatabaseItem item) => items = items.rebuild((b) => b
    ..removeWhere((i) => i.id == item.id)
    ..add(item));
}
