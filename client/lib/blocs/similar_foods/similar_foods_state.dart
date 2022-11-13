import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:gutlogic/models/irritant/intensity.dart';

import '../../models/food_reference/food_reference.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class SimilarFoodsState extends Equatable {
  const SimilarFoodsState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class SimilarFoodsLoading extends SimilarFoodsState {
  const SimilarFoodsLoading();
}

class SimilarFoodsLoaded extends SimilarFoodsState {
  final BuiltList<FoodReference> foods;
  final BuiltMap<FoodReference, Intensity> maxIntensities;

  const SimilarFoodsLoaded({required this.foods, required this.maxIntensities});

  @override
  List<Object?> get props => [foods, maxIntensities];
}

class SimilarFoodsError extends SimilarFoodsState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  SimilarFoodsError({required this.message}) : report = null;

  SimilarFoodsError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory SimilarFoodsError.fromReport(ErrorReport report) =>
      SimilarFoodsError.fromError(error: report.error, trace: report.trace);
}
