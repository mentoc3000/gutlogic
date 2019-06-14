import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

abstract class DatabaseRepository {
  BuiltList<DatabaseItem> items;

  DatabaseRepository();

  Future<BuiltList<DatabaseItem>> fetchAll() => Future(() => items);

// TODO: throw error if duplicate id
  void insert(DatabaseItem item) => items = items.rebuild((b) => b..add(item));

  void insertAll(Iterable<DatabaseItem> items) => items.map(this.insert);

  void delete(String id) =>
      items = items.rebuild((b) => b..removeWhere((i) => i.id == id));

  void upsert(DatabaseItem item) => items = items.rebuild((b) => b
    ..removeWhere((i) => i.id == item.id)
    ..add(item));

}
