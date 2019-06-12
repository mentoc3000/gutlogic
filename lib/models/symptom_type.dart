import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gut_ai/models/model_interfaces.dart';

part 'symptom_type.g.dart';

abstract class SymptomType implements Built<SymptomType, SymptomTypeBuilder>, Searchable {
  static Serializer<SymptomType> get serializer => _$symptomTypeSerializer;

  String get name;

  SymptomType._();
  factory SymptomType({String name}) = _$SymptomType._;
  factory SymptomType.fromBuilder([updates(SymptomTypeBuilder b)]) = _$SymptomType;

  String searchHeading() => this.name;
}