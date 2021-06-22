import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FoodsLoading extends FoodState with SearchableLoading {}

mixin Query {
  String get query;
}

class NoFoodsFound extends FoodState with Query {
  @override
  final String query;

  NoFoodsFound({required this.query});

  @override
  List<Object?> get props => [query];
}

class FoodsLoaded extends FoodState with Query, SearchableLoaded {
  @override
  final String query;

  @override
  final BuiltList<Food> items;

  FoodsLoaded({required this.query, required this.items});

  @override
  List<Object?> get props => [query, items];
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
