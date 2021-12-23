import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/symptom_type_repository.dart';
import 'package:test/test.dart';

void main() {
  group('Symptom Type Repository', () {
    test('fetches all symptom types', () async {
      final symptomTypeRepository = SymptomTypeRepository();
      final Iterable<SymptomType> symptomTypes = await symptomTypeRepository.fetchAll();
      expect(symptomTypes.length, 15);
      final names = symptomTypes.map((t) => t.name).toList();
      expect(names.contains('Gas'), true);
      expect(names.contains('Constipation'), true);
      expect(names.contains('Bloating'), true);
    });

    test('fetches query', () async {
      final symptomTypeRepository = SymptomTypeRepository();
      final Iterable<SymptomType> symptomTypes = await symptomTypeRepository.fetchQuery('Gas');
      expect(symptomTypes.length, 1);
      final names = symptomTypes.map((t) => t.name).toList();
      expect(names.contains('Gas'), true);
    });

    test('fetches all when no query is provided', () async {
      final symptomTypeRepository = SymptomTypeRepository();
      final Iterable<SymptomType> symptomTypes = await symptomTypeRepository.fetchQuery('');
      expect(symptomTypes.length, 15);
      final names = symptomTypes.map((t) => t.name).toList();
      expect(names.contains('Gas'), true);
      expect(names.contains('Constipation'), true);
      expect(names.contains('Bloating'), true);
    });

    test('fetches item', () async {
      final symptomTypeRepository = SymptomTypeRepository();
      final symptomType = await symptomTypeRepository.fetchItem('glst-1');
      expect(symptomType.name, 'Aching');
    });

    test('streams query', () async {
      final symptomTypeRepository = SymptomTypeRepository();
      final allSymptomTypes = await symptomTypeRepository.fetchAll();
      final gas = allSymptomTypes.where((symptomType) => symptomType.name == 'Gas').toBuiltList();
      await expectLater(symptomTypeRepository.streamQuery('Gas'), emits(gas));
    });
  });
}
