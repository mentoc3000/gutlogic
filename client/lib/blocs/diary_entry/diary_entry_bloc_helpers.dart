import 'dart:async';
import 'package:pedantic/pedantic.dart';
import '../../resources/diary_repositories/diary_repository_helpers.dart';
import '../bloc_helpers.dart';
import 'diary_entry_event.dart';
import 'diary_entry_state.dart';

mixin DiaryEntryMapper<TStreamData, TEvent, TState> on StreamSubscriber<TStreamData, TState> {
  late final DiaryEntryStreamer diaryEntryStreamer;
  late final DiaryEntryDeleter diaryEntryDeleter;
  late final DiaryEntryUpdater diaryEntryUpdater;

  Stream<TState> mapDiaryEntryEventToState(TEvent event) async* {
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
