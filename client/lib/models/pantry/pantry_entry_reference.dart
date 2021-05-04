import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../model_interfaces.dart';
import '../sensitivity.dart';

part 'pantry_entry_reference.g.dart';

abstract class PantryEntryReference with Ided implements Built<PantryEntryReference, PantryEntryReferenceBuilder> {
  static Serializer<PantryEntryReference> get serializer => _$pantryEntryReferenceSerializer;

  Sensitivity get sensitivity;

  PantryEntryReference._();

  factory PantryEntryReference({required String id, required Sensitivity sensitivity}) = _$PantryEntryReference._;

  factory PantryEntryReference.fromBuilder(
      [PantryEntryReferenceBuilder Function(PantryEntryReferenceBuilder) updates]) = _$PantryEntryReference;
}
