import 'package:equatable/equatable.dart';

import '../../models/diary_entry/symptom_entry.dart';
import '../../models/severity.dart';
import '../../models/symptom.dart';
import '../../models/symptom_type.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';

abstract class SymptomEntryEvent extends Equatable {
  const SymptomEntryEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class LoadSymptomEntry extends SymptomEntryEvent with LoadDiaryEntry {
  @override
  final SymptomEntry diaryEntry;

  const LoadSymptomEntry(this.diaryEntry);
}

class CreateFromAndStreamSymptomEntry extends SymptomEntryEvent implements Tracked {
  final SymptomType symptomType;

  const CreateFromAndStreamSymptomEntry(this.symptomType);

  @override
  List<Object?> get props => [symptomType];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_symptom_entry');
}

class StreamSymptomEntry extends SymptomEntryEvent with StreamDiaryEntry {
  @override
  final SymptomEntry diaryEntry;

  const StreamSymptomEntry(this.diaryEntry);
}

class DeleteSymptomEntry extends SymptomEntryEvent with DeleteDiaryEntry implements Tracked {
  @override
  final SymptomEntry diaryEntry;

  const DeleteSymptomEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_symptom_entry');
}

class UpdateSymptomEntry extends SymptomEntryEvent with UpdateDiaryEntry implements DebouncedEvent, Tracked {
  @override
  final SymptomEntry diaryEntry;

  const UpdateSymptomEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_symptom_entry');
}

class UpdateSymptomEntryDateTime extends SymptomEntryEvent
    with UpdateDiaryEntryDateTime
    implements DebouncedEvent, Tracked {
  @override
  final DateTime dateTime;

  const UpdateSymptomEntryDateTime(this.dateTime);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_symptom_entry', 'dateTime');
}

class UpdateSymptomEntryNotes extends SymptomEntryEvent with UpdateDiaryEntryNotes implements DebouncedEvent, Tracked {
  @override
  final String notes;

  const UpdateSymptomEntryNotes(this.notes);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_symptom_entry', 'notes');
}

class UpdateSymptomType extends SymptomEntryEvent with DebouncedEvent implements Tracked {
  final SymptomType symptomType;

  const UpdateSymptomType(this.symptomType);

  @override
  List<Object?> get props => [symptomType];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_symptom_entry', 'type');

  @override
  String toString() => 'UpdateSymptomType { symptomName: ${symptomType.name} } }';
}

class UpdateSymptomName extends SymptomEntryEvent with DebouncedEvent implements Tracked {
  final String symptomName;

  const UpdateSymptomName(this.symptomName);

  @override
  List<Object?> get props => [symptomName];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_symptom_entry', 'symptom_name');

  @override
  String toString() => 'UpdateSymptomName { symptomName: $symptomName } }';
}

class UpdateSymptom extends SymptomEntryEvent with DebouncedEvent implements Tracked {
  final Symptom symptom;

  const UpdateSymptom(this.symptom);

  @override
  List<Object?> get props => [symptom];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'symptom');

  @override
  String toString() => 'UpdateSymptom { symptomName: ${symptom.symptomType.name} }';
}

class UpdateSeverity extends SymptomEntryEvent with DebouncedEvent implements Tracked {
  final Severity severity;

  const UpdateSeverity(this.severity);

  @override
  List<Object?> get props => [severity];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'severity');

  @override
  String toString() => 'UpdateSeverity { severity: $severity } }';
}

class ThrowSymptomEntryError extends SymptomEntryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowSymptomEntryError({required this.report});

  factory ThrowSymptomEntryError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowSymptomEntryError(report: ErrorReport(error: error, trace: trace));
}
