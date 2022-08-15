import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/analysis_service.dart';
import '../bloc_helpers.dart';
import 'diary_streak_state.dart';

class DiaryStreakCubit extends Cubit<DiaryStreakState>
    with StreamSubscriber<BuiltMap<DateTime, int>, DiaryStreakState> {
  final AnalysisService analysisService;
  final int dateCount;

  DiaryStreakCubit({required this.analysisService, required this.dateCount}) : super(const DiaryStreakLoading()) {
    streamSubscription = analysisService.diaryStreak(count: dateCount).listen(_onData, onError: _onError);
  }

  factory DiaryStreakCubit.fromContext(BuildContext context, {required int dateCount}) {
    return DiaryStreakCubit(analysisService: context.read<AnalysisService>(), dateCount: dateCount);
  }

  void _onData(BuiltMap<DateTime, int> recentSeverities) {
    emit(DiaryStreakLoaded(recentSeverities));
  }

  void _onError(Object error, StackTrace trace) {
    emit(DiaryStreakError.fromError(error: error, trace: trace));
  }
}
