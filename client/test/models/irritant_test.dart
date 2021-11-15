import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Irritant', () {
    test('constructs simple object', () {
      final irritant = Irritant(name: 'Fructan', concentration: 1, dosePerServing: 1);
      expect(irritant.name, 'Fructan');
    });

    test('is equatable', () {
      Irritant constructIrritant() => Irritant(name: 'Fructan', concentration: 1, dosePerServing: 1);
      expect(constructIrritant(), constructIrritant());
    });

    test('is deserializable', () {
      final irritantJson = {'name': 'Fructan', 'concentration': 0.1, 'dosePerServing': 1E-4};
      final irritant = serializers.deserializeWith(Irritant.serializer, irritantJson)!;
      expect(irritant.name, 'Fructan');
    });

    test('is serializable', () {
      final irritant = Irritant(name: 'Fructan', concentration: 1, dosePerServing: 2);
      final irritantJson = {'name': 'Fructan', 'concentration': 1.0, 'dosePerServing': 2.0};
      expect(serializers.serialize(irritant),
          {'\$': 'Irritant', 'name': 'Fructan', 'concentration': 1.0, 'dosePerServing': 2.0});
      expect(serializers.serializeWith(Irritant.serializer, irritant), irritantJson);
    });

    test('has a search heading', () {
      final irritant = Irritant(name: 'Fructan', concentration: 1, dosePerServing: 1);
      expect(irritant.searchHeading(), irritant.name);
    });
  });
}
