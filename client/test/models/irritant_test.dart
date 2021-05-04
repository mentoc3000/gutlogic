import 'package:gutlogic/models/irritant.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Irritant', () {
    test('constructs simple object', () {
      final irritant = Irritant(name: 'Fructan');
      expect(irritant.name, 'Fructan');
    });

    test('is equatable', () {
      Irritant constructMedicine() => Irritant.fromBuilder((b) => b..name = 'Fructan');
      expect(constructMedicine(), constructMedicine());
    });

    test('is deserializable', () {
      final irritantJson = {'name': 'Fructan'};
      final irritant = serializers.deserializeWith(Irritant.serializer, irritantJson)!;
      expect(irritant.name, 'Fructan');
    });

    test('is serializable', () {
      final irritant = Irritant.fromBuilder((b) => b..name = 'Fructan');
      expect(serializers.serialize(irritant), {'\$': 'Irritant', 'name': 'Fructan'});
      expect(serializers.serializeWith(Irritant.serializer, irritant), {'name': 'Fructan'});
    });

    test('has a search heading', () {
      final irritant = Irritant.fromBuilder((b) => b..name = 'Fructan');
      expect(irritant.searchHeading(), irritant.name);
    });
  });
}
