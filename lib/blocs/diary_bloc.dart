import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import './diary_event.dart';
import './diary_state.dart';
import '../resources/diary_entries_repository.dart';
import '../models/diary_entry.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  DiaryEntriesRepository diaryEntriesRepository;

  DiaryBloc({@required this.diaryEntriesRepository});

  @override
  DiaryState get initialState => DiaryUninitialized();

  @override
  Stream<DiaryState> mapEventToState(
    DiaryEvent event,
  ) async* {
    if (event is Fetch) {
      try {
        BuiltList<DiaryEntry> diaryEntries = await diaryEntriesRepository.fetchAll();
        yield DiaryLoaded(diaryEntries: diaryEntries);
      } catch (_) {
        yield DiaryError();
      }
    }
  }

}
