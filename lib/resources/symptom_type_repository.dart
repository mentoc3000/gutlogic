import 'dart:async';
import '../models/symptom.dart';

class SymptomTypeRepository {

  SymptomTypeRepository();

  Future<List<SymptomType>> fetchAllSymptomTypes() async {
    // await Future.delayed(Duration(seconds: 1));
    return SymptomType.values;
  }

  Future<List<SymptomType>> fetchQuery(String query) async {
    if (query == '') {
      return fetchAllSymptomTypes();
    }
    return SymptomType.values
        .where((f) => f.toString().contains(query))
        .toList();
  }
}
