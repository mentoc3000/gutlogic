class Symptom {
  SymptomType symptomType;
  int severity;

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
