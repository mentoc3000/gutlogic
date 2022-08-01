import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food_reference/food_reference.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

class FoodsSuggestionState extends Equatable {
  const FoodsSuggestionState();

  @override
  List<Object?> get props => [];
}

class FoodsSuggestionLoading extends FoodsSuggestionState {
  const FoodsSuggestionLoading();
}

class FoodsSuggestionLoaded extends FoodsSuggestionState {
  final BuiltList<FoodReference> suggestedFoods;

  const FoodsSuggestionLoaded(this.suggestedFoods);

  @override
  List<Object?> get props => [suggestedFoods];
}

class FoodsSuggestionError extends FoodsSuggestionState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodsSuggestionError({required this.message}) : report = null;

  FoodsSuggestionError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodsSuggestionError.fromReport(ErrorReport report) {
    return FoodsSuggestionError.fromError(error: report.error, trace: report.trace);
  }
}
