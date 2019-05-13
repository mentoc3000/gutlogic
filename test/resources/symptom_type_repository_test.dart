import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/resources/symptom_type_repository.dart';
import 'package:gut_ai/models/symptom.dart';

void main() {
  group('Symptom Type Repository', () {
    test('fetches all symptom types', () async {
      SymptomTypeRepository symptomTypeRepository = SymptomTypeRepository();
      List<SymptomType> symptomTypes = await symptomTypeRepository.fetchAll();
      expect(symptomTypes.length, 3);
      expect(symptomTypes.contains(SymptomType.gas), true);
      expect(symptomTypes.contains(SymptomType.constipation), true);
      expect(symptomTypes.contains(SymptomType.bloating), true);
    });
  });
}

