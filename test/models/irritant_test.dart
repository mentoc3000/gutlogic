import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/irritant.dart';

void main() {
  group('Irritant', () {
    test('constructs empty object', () {
      Irritant irritant = Irritant();
      expect(irritant.name, null);
    });

    test('constructs simple object', () {
      Irritant irritant = Irritant(name: 'Fructan');
      expect(irritant.name, 'Fructan');
    });

    test('is equatable', () {
      final constructIrritant = () => Irritant(name: 'Fructan');
      expect(constructIrritant(), constructIrritant());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> irritantJson = {
        'name': 'Fructan',
      };
      Irritant irritant = Irritant.fromJson(irritantJson);
      expect(irritant.name, 'Fructan');
    });

    test('is serializable', () {
      Irritant irritant = Irritant(name: 'Fructan');
      expect(irritant.toJson(), {'name': 'Fructan'});
    });
  });
}
