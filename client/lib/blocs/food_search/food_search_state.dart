import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class FoodSearchState extends Equatable {
  const FoodSearchState();

  @override
  List<Object?> get props => [];
}

class FoodSearchLoading extends FoodSearchState with SearchableLoading {}

mixin Query {
  String get query;
}

class NoFoodsFound extends FoodSearchState with Query {
  @override
  final String query;

  NoFoodsFound({required this.query});

  @override
  List<Object?> get props => [query];
}

class FoodSearchLoaded extends FoodSearchState with Query, SearchableLoaded {
  @override
  final String query;

  @override
  final BuiltList<Food> items;

  FoodSearchLoaded({required this.query, required this.items});

  @override
  List<Object?> get props => [query, items];
}

class FoodSearchError extends FoodSearchState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  FoodSearchError({required this.message}) : report = null;

  FoodSearchError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory FoodSearchError.fromReport(ErrorReport report) {
    return FoodSearchError.fromError(error: report.error, trace: report.trace);
  }
}
