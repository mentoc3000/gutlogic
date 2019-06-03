import 'dart:async';
import 'package:bloc/bloc.dart';
import './diary_entries_event.dart';
import './diary_entries_state.dart';

class DiaryEntryBloc extends Bloc<DiaryEntriesEvent, DiaryEntriesState> {
  @override
  DiaryEntriesState get initialState => DiaryEntriesNotLoaded();

  @override
  Stream<DiaryEntriesState> mapEventToState(
    DiaryEntriesEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
