import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:gutlogic/models/irritant/intensity.dart';

import '../../models/food_group_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class FoodGroupSearchState extends Equatable {
  const FoodGroupSearchState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodGroupSearchLoading extends FoodGroupSearchState {
  const FoodGroupSearchLoading();
}

class FoodGroupSearchLoaded extends FoodGroupSearchState {
  final BuiltList<FoodGroupEntry> foods;
  final BuiltMap<FoodGroupEntry, Intensity> maxIntensities;

  const FoodGroupSearchLoaded({required this.foods, required this.maxIntensities});

  factory FoodGroupSearchLoaded.empty() {
    return FoodGroupSearchLoaded(
      foods: BuiltList<FoodGroupEntry>(),
      maxIntensities: BuiltMap<FoodGroupEntry, Intensity>(),
    );
  }

  @override
  List<Object?> get props => [foods, maxIntensities];
}

class FoodGroupSearchError extends FoodGroupSearchState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodGroupSearchError({required this.message}) : report = null;

  FoodGroupSearchError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodGroupSearchError.fromReport(ErrorReport report) {
    return FoodGroupSearchError.fromError(error: report.error, trace: report.trace);
  }
}
