import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../resources/firebase/untyped_data.dart';
import '../serializers.dart';

part 'preferences.g.dart';

abstract class Preferences implements Built<Preferences, PreferencesBuilder> {
  static Serializer<Preferences> get serializer => _$preferencesSerializer;

  BuiltSet<String>? get irritantsExcluded;

  Preferences._();

  factory Preferences({BuiltSet<String>? irritantsExcluded}) = _$Preferences._;

  factory Preferences.fromBuilder([PreferencesBuilder Function(PreferencesBuilder) updates]) = _$Preferences;

  static Preferences? deserialize(UntypedData? value) {
    return serializers.deserializeWith(Preferences.serializer, value);
  }

  static UntypedData? serialize(Preferences value) {
    return serializers.serializeWith(Preferences.serializer, value) as UntypedData;
  }
}
