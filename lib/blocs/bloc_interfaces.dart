import 'dart:async';
import '../models/model_interfaces.dart';

abstract class GutAiBloc {

}

abstract class SearchableBloc extends GutAiBloc {
  Stream<List<Searchable>> get all;
  void fetchAll();
  void fetchQuery(String query);
}