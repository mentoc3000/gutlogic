import 'package:equatable/equatable.dart';

import '../../models/application_user.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class ChangePasswordState extends Equatable {
  /// The user that is being modified.
  final ApplicationUser user;

  const ChangePasswordState({required this.user});

  @override
  List<Object?> get props => [user];
}

class ChangePasswordEntry extends ChangePasswordState {
  /// True if the updated password is valid.
  final bool isValid;

  /// True if the updated password is repeated.
  final bool isRepeated;

  const ChangePasswordEntry({
    required ApplicationUser user,
    required this.isValid,
    required this.isRepeated,
  }) : super(user: user);

  @override
  List<Object?> get props => [user, isValid, isRepeated];

  @override
  String toString() => 'ChangePasswordEntry { id: ${user.id}, isValid: $isValid, isRepeated: $isRepeated }';
}

class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading({required user}) : super(user: user);

  @override
  String toString() => 'ChangePasswordLoading { id: ${user.id} }';
}

class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess({required user}) : super(user: user);

  @override
  String toString() => 'ChangePasswordSuccess { id: ${user.id} }';
}

class ChangePasswordError extends ChangePasswordState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  const ChangePasswordError({
    required ApplicationUser user,
    required this.message,
  })  : report = null,
        super(user: user);

  factory ChangePasswordError.wrongCurrentPassword({required ApplicationUser user}) {
    return ChangePasswordError(user: user, message: 'Sorry, your current password doesn\'t match.');
  }

  factory ChangePasswordError.invalidCreatedPassword({required ApplicationUser user}) {
    return ChangePasswordError(user: user, message: 'Sorry, that password is invalid.');
  }

  factory ChangePasswordError.invalidUpdatedPassword({required ApplicationUser user}) {
    return ChangePasswordError(user: user, message: 'Sorry, your updated password is invalid.');
  }

  ChangePasswordError.fromError({required ApplicationUser user, required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace),
        super(user: user);

  @override
  String toString() => 'ChangePasswordError { id: ${user.id}, message: $message }';
}
