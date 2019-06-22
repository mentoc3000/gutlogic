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
    return items.rebuild((b) => b
      ..where(
          (f) => f.queryText().toLowerCase().contains(query.toLowerCase())));
  }
}
