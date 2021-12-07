import 'package:equatable/equatable.dart';

import '../../models/food_group.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class FoodGroupsState extends Equatable {
  const FoodGroupsState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodGroupsLoading extends FoodGroupsState {
  const FoodGroupsLoading();
}

class FoodGroupsLoaded extends FoodGroupsState {
  final Iterable<FoodGroup> foodGroups;

  FoodGroupsLoaded({required this.foodGroups});

  @override
  List<Object?> get props => [foodGroups];
}

class FoodGroupsError extends FoodGroupsState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodGroupsError({required this.message}) : report = null;

  FoodGroupsError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodGroupsError.fromReport(ErrorReport report) =>
      FoodGroupsError.fromError(error: report.error, trace: report.trace);
}
