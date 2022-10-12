import 'package:equatable/equatable.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class Subscribed extends SubscriptionState {
  const Subscribed();
}

class SubscriptionPending extends SubscriptionState {
  const SubscriptionPending();
}

class NotSubscribed extends SubscriptionState {
  const NotSubscribed();
}

class SubscriptionError extends SubscriptionState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  SubscriptionError({required this.message}) : report = null;

  SubscriptionError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory SubscriptionError.fromReport(ErrorReport report) =>
      SubscriptionError.fromError(error: report.error, trace: report.trace);
}
