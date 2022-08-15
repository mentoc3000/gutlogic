import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/sensitivity/sensitivity_level.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class FoodCountByIrritantState extends Equatable {
  const FoodCountByIrritantState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodCountByIrritantLoading extends FoodCountByIrritantState {
  const FoodCountByIrritantLoading();
}

class FoodCountByIrritantLoaded extends FoodCountByIrritantState {
  final BuiltMap<String, BuiltMap<SensitivityLevel, int>> foodCountByIrritant;

  const FoodCountByIrritantLoaded(this.foodCountByIrritant);

  @override
  List<Object?> get props => [foodCountByIrritant];
}

class FoodCountByIrritantError extends FoodCountByIrritantState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodCountByIrritantError({required this.message}) : report = null;

  FoodCountByIrritantError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodCountByIrritantError.fromReport(ErrorReport report) =>
      FoodCountByIrritantError.fromError(error: report.error, trace: report.trace);
}
