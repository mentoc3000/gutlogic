import 'package:test/test.dart';
import 'package:gut_ai/resources/symptom_type_repository.dart';
import 'package:gut_ai/models/symptom_type.dart';

void main() {
  group('Symptom Type Repository', () {
    test('fetches all symptom types', () async {
      SymptomTypeRepository symptomTypeRepository = SymptomTypeRepository();
      Iterable<SymptomType> symptomTypes = await symptomTypeRepository.fetchAll();
      expect(symptomTypes.length, 3);
      List<String> names = symptomTypes.map((t) => t.name).toList();
      expect(names.contains('Gas'), true);
      expect(names.contains('Constipation'), true);
      expect(names.contains('Bloating'), true);
    });
  });
}

