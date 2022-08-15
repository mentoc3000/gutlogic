import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/severity.dart';
import '../../resources/analysis_service.dart';
import '../bloc_helpers.dart';
import 'recent_severity_state.dart';

class RecentSeverityCubit extends Cubit<RecentSeverityState>
    with StreamSubscriber<BuiltMap<DateTime, Severity?>, RecentSeverityState> {
  final AnalysisService analysisService;
  final int dateCount;

  RecentSeverityCubit({required this.analysisService, required this.dateCount}) : super(const RecentSeverityLoading()) {
    streamSubscription = analysisService.recentSeverity(count: dateCount).listen(_onData, onError: _onError);
  }

  factory RecentSeverityCubit.fromContext(BuildContext context, {required int dateCount}) {
    return RecentSeverityCubit(analysisService: context.read<AnalysisService>(), dateCount: dateCount);
  }

  void _onData(BuiltMap<DateTime, Severity?> recentSeverities) {
    emit(RecentSeverityLoaded(recentSeverities));
  }

  void _onError(Object error, StackTrace trace) {
    emit(RecentSeverityError.fromError(error: error, trace: trace));
  }
}
