import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/sensitivity/sensitivity_level.dart';
import '../../resources/analysis_service.dart';
import '../bloc_helpers.dart';
import 'food_count_by_irritant_state.dart';

class FoodCountByIrritantCubit extends Cubit<FoodCountByIrritantState>
    with StreamSubscriber<BuiltMap<String, BuiltMap<SensitivityLevel, int>>, FoodCountByIrritantState> {
  final AnalysisService analysisService;

  FoodCountByIrritantCubit({required this.analysisService}) : super(const FoodCountByIrritantLoading()) {
    streamSubscription = analysisService.foodCountByIrritantAndLevel().listen(_onData, onError: _onError);
  }

  factory FoodCountByIrritantCubit.fromContext(BuildContext context) {
    return FoodCountByIrritantCubit(analysisService: context.read<AnalysisService>());
  }

  void _onData(BuiltMap<String, BuiltMap<SensitivityLevel, int>> matrix) {
    emit(FoodCountByIrritantLoaded(matrix));
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodCountByIrritantError.fromError(error: error, trace: trace));
  }
}
