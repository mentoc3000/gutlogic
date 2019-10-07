import 'package:built_collection/built_collection.dart';
import '../models/symptom_type.dart';
import 'searchable_repository.dart';

class SymptomTypeRepository extends SearchableRepository<SymptomType> {
  BuiltList<SymptomType> items;

  SymptomTypeRepository() : super() {
    items = BuiltList<SymptomType>([
      SymptomType(name: 'Bloating'),
      SymptomType(name: 'Constipation'),
      SymptomType(name: 'Gas'),
    ]);
  }
}
