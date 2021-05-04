import 'dart:async';

import '../../models/diary_entry/symptom_entry.dart';
import '../../models/serializers.dart';
import '../../models/severity.dart';
import '../../models/symptom.dart';
import '../../models/symptom_type.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'diary_repository_helpers.dart';

SymptomEntry? deserialize(Map<String, dynamic> object) {
  return serializers.deserializeWith(SymptomEntry.serializer, object);
}

class SymptomEntryRepository
    with FirestoreRepository, DiaryEntryStreamer, DiaryEntryAdder, DiaryEntryDeleter, DiaryEntryUpdater {
  static Severity defaultSeverity = Severity.moderate;

  SymptomEntryRepository({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  Future<SymptomEntry?> createFrom(SymptomType symptomType) async {
    final symptomEntry = SymptomEntry(
      id: '',
      datetime: DateTime.now().toUtc(),
      symptom: Symptom(symptomType: symptomType, severity: defaultSeverity),
    );
    return add(symptomEntry);
  }

  Future<void> updateSeverity(SymptomEntry symptomEntry, Severity newSeverity) =>
      updateEntry(symptomEntry.rebuild((b) => b..symptom.severity = newSeverity));

  Future<void> updateSymptomName(SymptomEntry symptomEntry, String newSymptomName) =>
      updateEntry(symptomEntry.rebuild((b) => b..symptom.symptomType.name = newSymptomName));

  Future<void> updateSymptomType(SymptomEntry symptomEntry, SymptomType newSymptomType) =>
      updateEntry(symptomEntry.rebuild((b) => b..symptom.symptomType = newSymptomType.toBuilder()));

  Future<void> updateSymptom(SymptomEntry symptomEntry, Symptom newSymptom) =>
      updateEntry(symptomEntry.rebuild((b) => b..symptom = newSymptom.toBuilder()));
}
