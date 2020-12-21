import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';

abstract class BowelMovementEntryEvent extends Equatable {
  const BowelMovementEntryEvent();

  @override
  List<Object> get props => [];

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
  void track(AnalyticsService analyticsService) => analyticsService.logCreateBowelMovementEntry();
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
  void track(AnalyticsService analyticsService) => analyticsService.logDeleteBowelMovementEntry();
}

class UpdateBowelMovementEntry extends BowelMovementEntryEvent
    with UpdateDiaryEntry
    implements DebouncedEvent, TrackedEvent {
  @override
  final BowelMovementEntry diaryEntry;

  const UpdateBowelMovementEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateBowelMovementEntry();
}

class UpdateBowelMovementEntryDateTime extends BowelMovementEntryEvent
    with UpdateDiaryEntryDateTime
    implements DebouncedEvent, TrackedEvent {
  @override
  final DateTime dateTime;

  const UpdateBowelMovementEntryDateTime(this.dateTime);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateBowelMovementEntry(field: 'dateTime');
}

class UpdateBowelMovementEntryNotes extends BowelMovementEntryEvent
    with UpdateDiaryEntryNotes
    implements DebouncedEvent, TrackedEvent {
  @override
  final String notes;

  const UpdateBowelMovementEntryNotes(this.notes);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateBowelMovementEntry(field: 'notes');
}

class UpdateType extends BowelMovementEntryEvent with DebouncedEvent implements TrackedEvent {
  final int type;

  const UpdateType(this.type);

  @override
  List<Object> get props => [type];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateBowelMovementEntry(field: 'type');

  @override
  String toString() => 'UpdateType { type: $type } }';
}

class UpdateVolume extends BowelMovementEntryEvent with DebouncedEvent implements TrackedEvent {
  final int volume;

  const UpdateVolume(this.volume);

  @override
  List<Object> get props => [volume];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateBowelMovementEntry(field: 'volume');

  @override
  String toString() => 'UpdateVolume { volume: $volume } }';
}

class ThrowBowelMovementEntryError extends BowelMovementEntryEvent with Throw {
  @override
  final Object error;

  @override
  final StackTrace trace;

  const ThrowBowelMovementEntryError({@required this.error, @required this.trace});
}
