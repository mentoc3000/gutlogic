import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import './diary_entries_event.dart';
import './diary_entries_state.dart';
import '../resources/diary_entries_repository.dart';
import '../models/diary_entry.dart';

class DiaryEntriesBloc extends Bloc<DiaryEntriesEvent, DiaryEntriesState> {
  DiaryEntriesRepository diaryEntriesRepository;

  DiaryEntriesBloc({@required this.diaryEntriesRepository});

  @override
  DiaryEntriesState get initialState => DiaryEntriesNotLoaded();

  @override
  Stream<DiaryEntriesState> mapEventToState(DiaryEntriesEvent event) async* {
    if (event is LoadDiaryEntries) {
      yield* _mapLoadDiaryEntriesToState();
    } else if (event is AddDiaryEntry) {
      yield* _mapAddDiaryEntryToState(event);
    } else if (event is UpdateDiaryEntry) {
      yield* _mapUpdateDiaryEntryToState(event);
    } else if (event is DeleteDiaryEntry) {
      yield* _mapDeleteDiaryEntryToState(event);
    } 
  }

  Stream<DiaryEntriesState> _mapLoadDiaryEntriesToState() async* {
    try {
      final diaryEntries = await this.diaryEntriesRepository.fetchAllDiaryEntries();
      yield DiaryEntriesLoaded(
        diaryEntries.map(DiaryEntry.fromEntity).toList(),
      );
    } catch (_) {
      yield DiaryEntriesNotLoaded();
    }
  }

  Stream<DiaryEntriesState> _mapAddDiaryEntryToState(AddDiaryEntry event) async* {
    if (currentState is DiaryEntriesLoaded) {
      final List<DiaryEntry> updatedDiaryEntries =
          List.from((currentState as DiaryEntriesLoaded).diaryEntries)..add(event.diaryEntry);
      yield DiaryEntriesLoaded(updatedDiaryEntries);
      _saveDiaryEntries(updatedDiaryEntries);
    }
  }

  Stream<DiaryEntriesState> _mapUpdateDiaryEntryToState(UpdateDiaryEntry event) async* {
    if (currentState is DiaryEntriesLoaded) {
      final List<DiaryEntry> updatedDiaryEntries =
          (currentState as DiaryEntriesLoaded).diaryEntries.map((diaryEntry) {
        return diaryEntry.id == event.updatedDiaryEntry.id ? event.updatedDiaryEntry : diaryEntry;
      }).toList();
      yield DiaryEntriesLoaded(updatedDiaryEntries);
      _saveDiaryEntries(updatedDiaryEntries);
    }
  }

  Stream<DiaryEntriesState> _mapDeleteDiaryEntryToState(DeleteDiaryEntry event) async* {
    if (currentState is DiaryEntriesLoaded) {
      final updatedDiaryEntries = (currentState as DiaryEntriesLoaded)
          .diaryEntries
          .where((diaryEntry) => diaryEntry.id != event.diaryEntry.id)
          .toList();
      yield DiaryEntriesLoaded(updatedDiaryEntries);
      _saveDiaryEntries(updatedDiaryEntries);
    }
  }

  Future _saveDiaryEntries(List<DiaryEntry> diaryEntries) {
    return diaryEntriesRepository.saveDiaryEntries(
      diaryEntries.map((diaryEntry) => diaryEntry.toEntity()).toList(),
    );
  }
}
