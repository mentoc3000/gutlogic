import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/irritant/irritant.dart';
import '../../models/meal_element.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class MealElementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealElementLoading extends MealElementState {}

class MealElementLoaded extends MealElementState {
  final MealElement mealElement;
  final Food? food;
  final BuiltList<Irritant>? irritants;

  MealElementLoaded({required this.mealElement, required this.food, required this.irritants});

  @override
  List<Object?> get props => [mealElement, food, irritants];
}

class MealElementError extends MealElementState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  MealElementError({required this.message}) : report = null;

  MealElementError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory MealElementError.fromReport(ErrorReport report) =>
      MealElementError.fromError(error: report.error, trace: report.trace);

  static String buildMessage(dynamic error) =>
      connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString;
}
