import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/symptom_type.dart';
import 'searchable_repository.dart';

class SymptomTypeRepository implements SearchableRepository<SymptomType> {
  static final items = BuiltList<SymptomType>([
    SymptomType(id: 'glst-1', name: 'Aching'),
    SymptomType(id: 'glst-2', name: 'Belching'),
    SymptomType(id: 'glst-3', name: 'Bleeding'),
    SymptomType(id: 'glst-4', name: 'Bloating'),
    SymptomType(id: 'glst-5', name: 'Constipation'),
    SymptomType(id: 'glst-6', name: 'Cramps'),
    SymptomType(id: 'glst-7', name: 'Diarrhea'),
    SymptomType(id: 'glst-8', name: 'Gas'),
    SymptomType(id: 'glst-9', name: 'Headache'),
    SymptomType(id: 'glst-10', name: 'Heartburn'),
    SymptomType(id: 'glst-11', name: 'Nausea'),
    SymptomType(id: 'glst-12', name: 'Pain'),
    SymptomType(id: 'glst-13', name: 'Vomiting'),
  ]);

  SymptomTypeRepository() : super();

  Future<BuiltList<SymptomType>> fetchAll() async => items;

  @override
  Future<BuiltList<SymptomType>> fetchQuery(String query) async {
    if (query.isEmpty) {
      return fetchAll();
    }
    return items.rebuild((ListBuilder<SymptomType> b) =>
        b..where((SymptomType f) => f.queryText().toLowerCase().contains(query.toLowerCase())));
  }

  Future<SymptomType> fetchItem(String id) async {
    return items.firstWhere((symptomType) => symptomType.id == id);
  }

  @override
  Stream<BuiltList<SymptomType>> streamQuery(String query) => Stream.fromFuture(fetchQuery(query));
}
