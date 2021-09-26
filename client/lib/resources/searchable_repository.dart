import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../models/model_interfaces.dart';

abstract class SearchableRepository<T extends Searchable> {
  Stream<BuiltList<T>> streamQuery(String query);
}
