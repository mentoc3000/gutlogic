import 'package:equatable/equatable.dart';

import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';

abstract class BowelMovementEntryEvent extends Equatable {
  const BowelMovementEntryEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class LoadBowelMovementEntry extends BowelMovementEntryEvent with LoadDiaryEntry {
  @override
  final BowelMovementEntry diaryEntry;

  const LoadBowelMovementEntry(this.diaryEntry);
}

class CreateAndStreamBowelMovementEntry extends BowelMovementEntryEvent
    with CreateAndStreamDiaryEntry
    implements TrackedEvent {
  const CreateAndStreamBowelMovementEntry();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_bowel_movement_entry');
}

class StreamBowelMovementEntry extends BowelMovementEntryEvent with StreamDiaryEntry {
  @override
  final BowelMovementEntry diaryEntry;

  const StreamBowelMovementEntry(this.diaryEntry);
}

class DeleteBowelMovementEntry extends BowelMovementEntryEvent with DeleteDiaryEntry implements TrackedEvent {
  @override
  final BowelMovementEntry diaryEntry;

  const DeleteBowelMovementEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_bowel_movement_entry');
}

class UpdateBowelMovementEntry extends BowelMovementEntryEvent
    with UpdateDiaryEntry
    implements DebouncedEvent, TrackedEvent {
  @override
  final BowelMovementEntry diaryEntry;

  const UpdateBowelMovementEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_bowel_movement_entry');
}

class UpdateBowelMovementEntryDateTime extends BowelMovementEntryEvent
    with UpdateDiaryEntryDateTime
    implements DebouncedEvent, TrackedEvent {
  @override
  final DateTime dateTime;

  const UpdateBowelMovementEntryDateTime(this.dateTime);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_bowel_movement_entry', 'dateTime');
}

class UpdateBowelMovementEntryNotes extends BowelMovementEntryEvent
    with UpdateDiaryEntryNotes
    implements DebouncedEvent, TrackedEvent {
  @override
  final String notes;

  const UpdateBowelMovementEntryNotes(this.notes);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_bowel_movement_entry', 'notes');
}

class UpdateType extends BowelMovementEntryEvent with DebouncedEvent implements TrackedEvent {
  final int type;

  const UpdateType(this.type);

  @override
  List<Object?> get props => [type];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_bowel_movement_entry', 'type');

  @override
  String toString() => 'UpdateType { type: $type } }';
}

class UpdateVolume extends BowelMovementEntryEvent with DebouncedEvent implements TrackedEvent {
  final int volume;

  const UpdateVolume(this.volume);

  @override
  List<Object?> get props => [volume];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_bowel_movement_entry', 'volume');

  @override
  String toString() => 'UpdateVolume { volume: $volume } }';
}

class ThrowBowelMovementEntryError extends BowelMovementEntryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowBowelMovementEntryError({required this.report});

  factory ThrowBowelMovementEntryError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowBowelMovementEntryError(report: ErrorReport(error: error, trace: trace));
}
