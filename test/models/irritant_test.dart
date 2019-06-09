import 'package:test/test.dart';
import 'package:gut_ai/models/irritant.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Irritant', () {
    test('constructs simple object', () {
      Irritant irritant = Irritant((b) => b..name = 'Fructan');
      expect(irritant.name, 'Fructan');
    });

    test('is equatable', () {
      final constructMedicine = () => Irritant((b) => b..name = 'Fructan');
      expect(constructMedicine(), constructMedicine());
    });

    test('is deserializable', () {
      Map<String, dynamic> irritantJson = {"name": "Fructan"};
      Irritant irritant =
          serializers.deserializeWith(Irritant.serializer, irritantJson);
      expect(irritant.name, 'Fructan');
    });

    test('is serializable', () {
      Irritant irritant = Irritant((b) => b..name = 'Fructan');
      expect(
          serializers.serialize(irritant), {"\$": "Irritant", "name": "Fructan"});
    });

    test('has a search heading', () {
      Irritant irritant = Irritant((b) => b..name = 'Fructan');
      expect(irritant.searchHeading(), irritant.name);
    });
  });
}
