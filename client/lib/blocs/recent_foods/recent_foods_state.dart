import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food_reference/food_reference.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

class RecentFoodsState extends Equatable {
  const RecentFoodsState();

  @override
  List<Object?> get props => [];
}

class RecentFoodsLoading extends RecentFoodsState {
  const RecentFoodsLoading();
}

class RecentFoodsLoaded extends RecentFoodsState {
  final BuiltList<FoodReference> recentFoods;

  const RecentFoodsLoaded(this.recentFoods);

  @override
  List<Object?> get props => [recentFoods];
}

class RecentFoodsError extends RecentFoodsState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  RecentFoodsError({required this.message}) : report = null;

  RecentFoodsError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory RecentFoodsError.fromReport(ErrorReport report) =>
      RecentFoodsError.fromError(error: report.error, trace: report.trace);
}
