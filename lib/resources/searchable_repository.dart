import 'dart:async';
import '../models/model_interfaces.dart';

abstract class SearchableRepository {
  Future<List<Searchable>> fetchAll();
  Future<List<Searchable>> fetchQuery(String query);
}