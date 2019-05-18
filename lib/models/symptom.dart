import 'package:equatable/equatable.dart';
import 'package:gut_ai/models/model_interfaces.dart';

class Symptom extends Equatable {
  SymptomType symptomType;
  double severity;

  Symptom({
    this.symptomType,
    this.severity,
  });

  factory Symptom.fromJson(Map<String, dynamic> parsedJson) {
    return Symptom(
      symptomType: parsedJson['symptomType'],
      severity: parsedJson['severity'],
    );
  }

  String name() {
    return this.symptomType.name;
  }
}

class SymptomType extends Equatable implements Searchable {

  final String name;

  SymptomType({this.name});

  String searchHeading() {
    return name;
  }
}