class Symptom {
  SymptomType symptomType;
  int severity;

  Symptom({
    this.symptomType,
    this.severity,
  });

  String name() {
    return SymptomName[this.symptomType];
  }
}

enum SymptomType {
  gas,
  constipation,
  bloating
}

const Map<SymptomType, String> SymptomName = {
  SymptomType.gas: "Gas",
  SymptomType.constipation: "Constipation",
  SymptomType.bloating: "Bloating",
};