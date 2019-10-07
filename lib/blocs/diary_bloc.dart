import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import './diary_event.dart';
import './diary_state.dart';
import './diary_entry_bloc.dart';
import './database_event.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  DiaryEntryBloc diaryEntryBloc;

  DiaryBloc({@required this.diaryEntryBloc});

  @override
  DiaryState get initialState => DiaryInitial();

  @override
  Stream<DiaryState> mapEventToState(
    DiaryEvent event,
  ) async* {
    if (event is LoadDiary) {
      try {
        diaryEntryBloc.dispatch(FetchAll());
        yield DiaryLoaded();
      } catch (_) {
        yield DiaryError();
      }
    }
  }

}
