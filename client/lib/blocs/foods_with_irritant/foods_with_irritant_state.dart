import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class FoodsWithIrritantState extends Equatable {
  const FoodsWithIrritantState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodsWithIrritantLoading extends FoodsWithIrritantState {
  const FoodsWithIrritantLoading();
}

class FoodsWithIrritantLoaded extends FoodsWithIrritantState {
  final BuiltMap<SensitivityLevel, int> sensitivityLevelCount;
  final BuiltMap<SensitivityLevel, BuiltList<FoodReference>> foodsBySensitivityLevel;

  const FoodsWithIrritantLoaded({required this.sensitivityLevelCount, required this.foodsBySensitivityLevel});

  @override
  List<Object?> get props => [sensitivityLevelCount, foodsBySensitivityLevel];
}

class FoodsWithIrritantError extends FoodsWithIrritantState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodsWithIrritantError({required this.message}) : report = null;

  FoodsWithIrritantError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodsWithIrritantError.fromReport(ErrorReport report) =>
      FoodsWithIrritantError.fromError(error: report.error, trace: report.trace);
}
