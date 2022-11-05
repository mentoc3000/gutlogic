import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodLoading extends FoodState {
  final FoodReference foodReference;

  const FoodLoading({required this.foodReference});

  @override
  List<Object?> get props => [foodReference];
}

class FoodLoaded extends FoodState {
  final Food food;

  const FoodLoaded({required this.food});

  @override
  List<Object?> get props => [food];
}

class FoodError extends FoodState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodError({required this.message}) : report = null;

  FoodError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodError.fromReport(ErrorReport report) => FoodError.fromError(error: report.error, trace: report.trace);
}
