import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/diary_repositories/diary_repository.dart';
import '../bloc_helpers.dart';
import 'diary_event.dart';
import 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> with StreamSubscriber {
  final DiaryRepository repository;

  DiaryBloc({required this.repository}) : super(DiaryLoading()) {
    on<StreamAllDiary>(_onStreamAll);
    on<Load>((event, emit) => emit(DiaryLoaded(event.diaryEntries)));
    on<Delete>(_onDelete);
    on<Undelete>((event, emit) => unawaited(repository.add(event.diaryEntry)));
    on<ThrowDiaryError>((event, emit) => emit(DiaryError.fromReport(event.report)));
  }

  static DiaryBloc fromContext(BuildContext context) {
    return DiaryBloc(repository: context.read<DiaryRepository>());
  }

  Future<void> _onStreamAll(StreamAllDiary event, Emitter<DiaryState> emit) async {
    try {
      emit(DiaryLoading());
      await streamSubscription?.cancel();
      streamSubscription = repository.streamAll().listen(
            (diaryEntries) => add(Load(diaryEntries: diaryEntries)),
            onError: (error, StackTrace trace) => add(ThrowDiaryError.fromError(error: error, trace: trace)),
          );
    } catch (error, trace) {
      emit(DiaryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onDelete(Delete event, Emitter<DiaryState> emit) async {
    try {
      await repository.delete(event.diaryEntry);
      emit(DiaryEntryDeleted(event.diaryEntry));
    } catch (error, trace) {
      emit(DiaryError.fromError(error: error, trace: trace));
    }
  }
}
