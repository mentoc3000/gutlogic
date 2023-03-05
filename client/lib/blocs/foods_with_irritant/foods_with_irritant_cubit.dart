import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../../resources/analysis_service.dart';
import '../bloc_helpers.dart';
import 'foods_with_irritant_state.dart';

class FoodsWithIrritantCubit extends Cubit<FoodsWithIrritantState>
    with StreamSubscriber<BuiltMap<SensitivityLevel, BuiltList<FoodReference>>, FoodsWithIrritantState> {
  final String irritantName;
  final AnalysisService analysisService;

  FoodsWithIrritantCubit({required this.analysisService, required this.irritantName})
      : super(const FoodsWithIrritantLoading()) {
    streamSubscription = analysisService
        .foodsWithIrritantBySensitivityLevel(irritantName: irritantName)
        .listen(_onData, onError: _onError);
  }

  factory FoodsWithIrritantCubit.fromContext(BuildContext context, {required String irritantName}) {
    return FoodsWithIrritantCubit(analysisService: context.read<AnalysisService>(), irritantName: irritantName);
  }

  void _onData(BuiltMap<SensitivityLevel, BuiltList<FoodReference>> foodMap) {
    final sensitivityLevelCount = {for (final e in foodMap.entries) e.key: e.value.length}.build();
    emit(FoodsWithIrritantLoaded(
      sensitivityLevelCount: sensitivityLevelCount,
      foodsBySensitivityLevel: foodMap,
    ));
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodsWithIrritantError.fromError(error: error, trace: trace));
  }
}
