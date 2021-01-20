import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/diary_entry/symptom_entry.dart';
import '../../models/severity.dart';
import '../../models/symptom.dart';
import '../../models/symptom_type.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';

abstract class SymptomEntryEvent extends Equatable {
  const SymptomEntryEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class LoadSymptomEntry extends SymptomEntryEvent with LoadDiaryEntry {
  @override
  final SymptomEntry diaryEntry;

  const LoadSymptomEntry(this.diaryEntry);
}

class CreateFromAndStreamSymptomEntry extends SymptomEntryEvent implements TrackedEvent {
  final SymptomType symptomType;

  const CreateFromAndStreamSymptomEntry(this.symptomType);

  @override
  List<Object> get props => [symptomType];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('create_symptom_entry');
}

class StreamSymptomEntry extends SymptomEntryEvent with StreamDiaryEntry {
  @override
  final SymptomEntry diaryEntry;

  const StreamSymptomEntry(this.diaryEntry);
}

class DeleteSymptomEntry extends SymptomEntryEvent with DeleteDiaryEntry implements TrackedEvent {
  @override
  final SymptomEntry diaryEntry;

  const DeleteSymptomEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_symptom_entry');
}

class UpdateSymptomEntry extends SymptomEntryEvent with UpdateDiaryEntry implements DebouncedEvent, TrackedEvent {
  @override
  final SymptomEntry diaryEntry;

  const UpdateSymptomEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry');
}

class UpdateSymptomEntryDateTime extends SymptomEntryEvent
    with UpdateDiaryEntryDateTime
    implements DebouncedEvent, TrackedEvent {
  @override
  final DateTime dateTime;

  const UpdateSymptomEntryDateTime(this.dateTime);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'dateTime');
}

class UpdateSymptomEntryNotes extends SymptomEntryEvent
    with UpdateDiaryEntryNotes
    implements DebouncedEvent, TrackedEvent {
  @override
  final String notes;

  const UpdateSymptomEntryNotes(this.notes);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'notes');
}

class UpdateSymptomType extends SymptomEntryEvent with DebouncedEvent implements TrackedEvent {
  final SymptomType symptomType;

  const UpdateSymptomType(this.symptomType);

  @override
  List<Object> get props => [symptomType];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'type');

  @override
  String toString() => 'UpdateSymptomType { symptomName: ${symptomType?.name} } }';
}

class UpdateSymptomName extends SymptomEntryEvent with DebouncedEvent implements TrackedEvent {
  final String symptomName;

  const UpdateSymptomName(this.symptomName);

  @override
  List<Object> get props => [symptomName];

  @override
  void track(AnalyticsService analyticsService) =>
      analyticsService.logUpdateEvent('update_symptom_entry', 'symptom_name');

  @override
  String toString() => 'UpdateSymptomName { symptomName: $symptomName } }';
}

class UpdateSymptom extends SymptomEntryEvent with DebouncedEvent implements TrackedEvent {
  final Symptom symptom;

  const UpdateSymptom(this.symptom);

  @override
  List<Object> get props => [symptom];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'symptom');

  @override
  String toString() => 'UpdateSymptom { symptomName: ${symptom?.symptomType?.name} }';
}

class UpdateSeverity extends SymptomEntryEvent with DebouncedEvent implements TrackedEvent {
  final Severity severity;

  const UpdateSeverity(this.severity);

  @override
  List<Object> get props => [severity];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_symptom_entry', 'severity');

  @override
  String toString() => 'UpdateSeverity { severity: $severity } }';
}

class ThrowSymptomEntryError extends SymptomEntryEvent with Throw {
  @override
  final Object error;

  @override
  final StackTrace trace;

  const ThrowSymptomEntryError({@required this.error, @required this.trace});
}
