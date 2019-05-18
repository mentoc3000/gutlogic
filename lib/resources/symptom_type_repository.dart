import 'dart:async';
import '../models/symptom.dart';

class SymptomTypeRepository {

  final List<SymptomType> allSymptomTypes = [
    SymptomType(name: 'Bloating'),
    SymptomType(name: 'Constipation'),
    SymptomType(name: 'Gas'),
  ];

  SymptomTypeRepository();

  Future<List<SymptomType>> fetchAll() async {
    // await Future.delayed(Duration(seconds: 1));
    return allSymptomTypes;
  }

  Future<List<SymptomType>> fetchQuery(String query) async {
    if (query == '') {
      return fetchAll();
    }
    return allSymptomTypes
        .where((f) => f.toString().contains(query))
        .toList();
  }
}
