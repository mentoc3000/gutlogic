import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/diary_repository_helpers.dart';
import 'diary_entry_event.dart';
import 'diary_entry_state.dart';

mixin DiaryEntryMapper<TStreamData, TState> on BlocBase<TState> {
  late final TimelineRepository timelineRepository;

  void onDeleteEntry(DeleteDiaryEntry event, Emitter<TState> emit) {
    unawaited(timelineRepository.delete(event.diaryEntry));
  }

  void onUpdateEntry(UpdateDiaryEntry event, Emitter<TState> emit) {
    unawaited(timelineRepository.updateEntry(event.diaryEntry));
  }

  void onUpdateDateTime(UpdateDiaryEntryDateTime event, Emitter<TState> emit) {
    final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
    unawaited(timelineRepository.updateDateTime(diaryEntry, event.dateTime));
  }

  void onUpdateNotes(UpdateDiaryEntryNotes event, Emitter<TState> emit) {
    final diaryEntry = (state as DiaryEntryLoaded).diaryEntry;
    unawaited(timelineRepository.updateNotes(diaryEntry, event.notes));
  }
}
