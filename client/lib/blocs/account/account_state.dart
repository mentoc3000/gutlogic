import 'package:equatable/equatable.dart';

import '../../models/application_user.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

abstract class AccountUserState {
  ApplicationUser get user;
}

class AccountUpdateReady extends AccountState implements AccountUserState {
  @override
  final ApplicationUser user;

  AccountUpdateReady({required this.user});

  @override
  List<Object?> get props => [user];
}

class AccountUpdateLoading extends AccountState implements AccountUserState {
  @override
  final ApplicationUser user;

  AccountUpdateLoading({required this.user});

  @override
  List<Object?> get props => [user];
}

class AccountUpdateSuccess extends AccountState implements AccountUserState {
  @override
  final ApplicationUser user;

  AccountUpdateSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AccountError extends AccountState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  AccountError({required user, required this.message}) : report = null;

  AccountError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
