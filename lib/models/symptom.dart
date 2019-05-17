import 'package:equatable/equatable.dart';

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
    return SymptomName[this.symptomType];
  }
}

enum SymptomType { gas, constipation, bloating }

const Map<SymptomType, String> SymptomName = {
  SymptomType.gas: "Gas",
  SymptomType.constipation: "Constipation",
  SymptomType.bloating: "Bloating",
};
