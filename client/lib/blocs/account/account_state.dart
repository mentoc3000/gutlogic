import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/application_user.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class AccountState extends Equatable {
  AccountState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class AccountReady extends AccountState {
  final ApplicationUser user;

  AccountReady({@required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'AccountReady { user.id: ${user?.id} }';
}

class AccountLoading extends AccountState {}

class AccountUpdated extends AccountState {}

class AccountLoggedOut extends AccountState {}

class AccountError extends AccountState with ErrorRecorder {
  @override
  final ErrorReport report;

  final String message;

  AccountError({@required this.message}) : report = null;

  AccountError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'AccountError { message: $message }';
}
