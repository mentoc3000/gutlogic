import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/irritant/irritant.dart';
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

class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final Food food;
  final BuiltList<Irritant>? irritants;

  const FoodLoaded({required this.food, required this.irritants});

  @override
  List<Object?> get props => [food, irritants];
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
