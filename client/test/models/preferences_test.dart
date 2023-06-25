import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/preferences/preferences.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Preferences', () {
    test('constructs simple object', () {
      final preferences = Preferences(irritantsExcluded: BuiltSet({'Lactose'}));
      expect(preferences.irritantsExcluded?.first, 'Lactose');
    });

    test('is equatable', () {
      Preferences constructPreferences() => Preferences(irritantsExcluded: BuiltSet({'Lactose'}));
      expect(constructPreferences(), constructPreferences());
    });

    test('is deserializable', () {
      final preferencesJson = {
        'irritantsExcluded': ['Lactose']
      };
      final preferences = serializers.deserializeWith(Preferences.serializer, preferencesJson)!;
      expect(preferences.irritantsExcluded?.first, 'Lactose');
    });

    test('is serializable', () {
      final preferences = Preferences(irritantsExcluded: BuiltSet({'Lactose'}));
      final preferencesJson = {
        'irritantsExcluded': ['Lactose']
      };
      expect(serializers.serialize(preferences), {'\$': 'Preferences', ...preferencesJson});
      expect(serializers.serializeWith(Preferences.serializer, preferences), preferencesJson);
    });
  });
}
