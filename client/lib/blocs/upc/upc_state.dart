import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class UpcState extends Equatable {
  const UpcState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class UpcScanning extends UpcState {
  const UpcScanning();
}

class UpcsFound extends UpcState {
  final Iterable<String> upcs;

  const UpcsFound({required this.upcs});

  @override
  List<Object?> get props => [upcs];
}

class FoodFound extends UpcState {
  final Food food;

  const FoodFound({required this.food});

  @override
  List<Object?> get props => [food];
}

class FoodNotFound extends UpcState {
  const FoodNotFound();
}

class UpcError extends UpcState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  UpcError({required this.message}) : report = null;

  UpcError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory UpcError.fromReport(ErrorReport report) => UpcError.fromError(error: report.error, trace: report.trace);
}
