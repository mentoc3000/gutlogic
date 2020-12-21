import 'dart:async';
import 'package:pedantic/pedantic.dart';
import '../../resources/diary_repositories/diary_repository_helpers.dart';
import '../bloc_helpers.dart';
import 'diary_entry_event.dart';
import 'diary_entry_state.dart';

mixin DiaryEntryMapper<E, S> on StreamSubscriber<E, S> {
  DiaryEntryStreamer diaryEntryStreamer;
  DiaryEntryDeleter diaryEntryDeleter;
  DiaryEntryUpdater diaryEntryUpdater;

  Stream<S> mapDiaryEntryEventToState(
    E event,
  ) async* {
    if (event is DeleteDiaryEntry) {
      unawaited(diaryEntryDeleter.delete(event.diaryEntry));
    }
    if (event is UpdateDiaryEntry) {
      unawaited(diaryEntryUpdater.updateEntry(event.diaryEntry));
    }
    if (event is UpdateDiaryEntryDateTime) {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
      unawaited(diaryEntryUpdater.updateDateTime(diaryEntry, event.dateTime));
    }
    if (event is UpdateDiaryEntryNotes) {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
      unawaited(diaryEntryUpdater.updateNotes(diaryEntry, event.notes));
    }
  }
}
