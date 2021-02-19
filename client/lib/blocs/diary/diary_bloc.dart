import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/diary_repository.dart';
import '../bloc_helpers.dart';
import 'diary_event.dart';
import 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> with StreamSubscriber {
  final DiaryRepository repository;

  DiaryBloc({@required this.repository}) : super(DiaryLoading());

  factory DiaryBloc.fromContext(BuildContext context) {
    return DiaryBloc(repository: context.read<DiaryRepository>());
  }
  @override
  Stream<DiaryState> mapEventToState(DiaryEvent event) async* {
    try {
      if (event is StreamAllDiary) {
        yield DiaryLoading();
        await streamSubscription?.cancel();
        streamSubscription = repository.streamAll().listen(
              (diaryEntries) => add(Load(diaryEntries: diaryEntries)),
              onError: (error, StackTrace trace) => add(Throw(error: error, trace: trace)),
            );
      }
      if (event is Load) {
        yield DiaryLoaded(event.diaryEntries);
      }
      if (event is Delete) {
        await repository.delete(event.diaryEntry);
        yield DiaryEntryDeleted(event.diaryEntry);
      }
      if (event is Undelete) {
        unawaited(repository.add(event.diaryEntry));
      }
      if (event is Throw) {
        yield DiaryError.fromError(error: event.error, trace: event.trace);
      }
    } catch (error, trace) {
      yield DiaryError.fromError(error: error, trace: trace);
    }
  }
}
