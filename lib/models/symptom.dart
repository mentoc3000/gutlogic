import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'symptom_type.dart';

part 'symptom.g.dart';

abstract class Symptom implements Built<Symptom, SymptomBuilder> {
  static Serializer<Symptom> get serializer => _$symptomSerializer;

  SymptomType get symptomType;
  double get severity;

  Symptom._();
  factory Symptom(
      {@required SymptomType symptomType,
      @required double severity}) = _$Symptom._;
  factory Symptom.fromBuilder([updates(SymptomBuilder b)]) = _$Symptom;

  String name() => this.symptomType.name;
}
