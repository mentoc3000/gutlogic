import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

// ignore: one_member_abstracts
abstract class SearchableRepository<T extends Searchable> {
  Stream<BuiltList<T>> streamQuery(String query);
}
