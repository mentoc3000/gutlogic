class Symptom {
  SymptomType symptomType;
  int severity;

  Symptom({
    this.symptomType,
    this.severity,
  });
}

enum SymptomType {
  gas,
  constipation,
  bloating
}