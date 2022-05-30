import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food_group_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class FoodGroupState extends Equatable {
  const FoodGroupState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodGroupLoading extends FoodGroupState {
  const FoodGroupLoading();
}

class FoodGroupLoaded extends FoodGroupState {
  final BuiltSet<FoodGroupEntry> foods;
  final BuiltMap<FoodGroupEntry, int?> maxIntensities;

  const FoodGroupLoaded({required this.foods, required this.maxIntensities});

  @override
  List<Object?> get props => [foods, maxIntensities];
}

class FoodGroupError extends FoodGroupState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodGroupError({required this.message}) : report = null;

  FoodGroupError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodGroupError.fromReport(ErrorReport report) {
    return FoodGroupError.fromError(error: report.error, trace: report.trace);
  }
}
