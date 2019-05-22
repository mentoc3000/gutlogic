import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'symptom_type.dart';

part 'symptom.g.dart';

@JsonSerializable()
class Symptom extends Equatable {
  SymptomType symptomType;
  double severity;

  Symptom({
    this.symptomType,
    this.severity,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      _$SymptomFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomToJson(this);

  String name() {
    return this.symptomType.name;
  }
}