import 'package:equatable/equatable.dart';
import 'symptom_type.dart';

class Symptom extends Equatable {
  SymptomType symptomType;
  double severity;

  Symptom({
    this.symptomType,
    this.severity,
  });

  factory Symptom.fromJson(Map<String, dynamic> parsedJson) {
    return Symptom(
      symptomType: SymptomType.fromJson(parsedJson['symptomType']),
      severity: parsedJson['severity'],
    );
  }

  String name() {
    return this.symptomType.name;
  }
}