import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'severity.dart';
import 'symptom_type.dart';

part 'symptom.g.dart';

abstract class Symptom implements Built<Symptom, SymptomBuilder> {
  static Serializer<Symptom> get serializer => _$symptomSerializer;

  SymptomType get symptomType;
  Severity get severity;

  Symptom._();

  factory Symptom({required SymptomType symptomType, required Severity severity}) = _$Symptom._;

  factory Symptom.fromBuilder([SymptomBuilder Function(SymptomBuilder) updates]) = _$Symptom;
}
