import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

mixin SearchableRepository<T extends Searchable> {
  Future<BuiltList<T>> fetchQuery(String query) => streamQuery(query).first;
  Stream<BuiltList<T>> streamQuery(String query);
}
