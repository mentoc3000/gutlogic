import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

abstract class SearchableRepository<T extends Searchable> {
  Future<BuiltList<T>> fetchQuery(String query);
  Stream<BuiltList<T>> streamQuery(String query);
}
