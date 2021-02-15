import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/food/food.dart';
import '../../models/meal_element.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class MealElementState extends Equatable {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class MealElementLoading extends MealElementState {}

class MealElementLoaded extends MealElementState {
  final MealElement mealElement;
  final Food food;

  MealElementLoaded({@required this.mealElement, this.food});

  @override
  List<Object> get props => [mealElement, food];

  @override
  String toString() => 'MealElementLoaded { MealElementId: ${mealElement?.id} }';
}

class MealElementError extends MealElementState with ErrorRecorder {
  @override
  final ErrorReport report;

  final String message;

  MealElementError({@required this.message}) : report = null;

  MealElementError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'MealElementError { message: $message }';

  static String buildMessage(dynamic error) =>
      connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString;
}
