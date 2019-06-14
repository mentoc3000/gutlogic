import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/symptom_type.dart';
import 'repository_interfaces.dart';

class SymptomTypeRepository extends SearchableRepository<SymptomType> {
  BuiltList<SymptomType> items;

  SymptomTypeRepository() : super() {
    items = BuiltList<SymptomType>([
      SymptomType(name: 'Bloating'),
      SymptomType(name: 'Constipation'),
      SymptomType(name: 'Gas'),
    ]);
  }

  Future<BuiltList<SymptomType>> fetchAll() async {
    // await Future.delayed(Duration(seconds: 1));
    return items;
  }

  Future<BuiltList<SymptomType>> fetchQuery(String query) async {
    if (query == '') {
      return fetchAll();
    }
    return items.where((f) => f.toString().contains(query));
  }
}
