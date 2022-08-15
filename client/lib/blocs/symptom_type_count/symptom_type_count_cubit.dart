import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/symptom_type.dart';
import '../../resources/analysis_service.dart';
import '../bloc_helpers.dart';
import 'symptom_type_count_state.dart';

class SymptomTypeCountCubit extends Cubit<SymptomTypeCountState>
    with StreamSubscriber<BuiltMap<SymptomType, int>, SymptomTypeCountState> {
  final AnalysisService analysisService;
  final DateTime? countSince;

  SymptomTypeCountCubit({required this.analysisService, this.countSince}) : super(const SymptomTypeCountLoading()) {
    streamSubscription = analysisService.symptomTypeCount(since: countSince).listen(_onData, onError: _onError);
  }

  factory SymptomTypeCountCubit.fromContext(BuildContext context, {DateTime? countSince}) {
    return SymptomTypeCountCubit(analysisService: context.read<AnalysisService>(), countSince: countSince);
  }

  void _onData(BuiltMap<SymptomType, int> symptomTypeCount) {
    emit(SymptomTypeCountLoaded(symptomTypeCount));
  }

  void _onError(Object error, StackTrace trace) {
    emit(SymptomTypeCountError.fromError(error: error, trace: trace));
  }
}
