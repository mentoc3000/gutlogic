import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:meta/meta.dart';

/// AuthException translates the weakly typed PlatformExceptions from firebase_auth into strongly typed exceptions.
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({@required this.message, this.code = 'unknown'});
}

/// Thrown when attempting to register or update a username to a username already in use by another account.
class DuplicateUsernameException extends AuthException {
  DuplicateUsernameException() : super(message: 'The supplied username is already in use by a different account.');
}

/// Thrown when attempting to link a provider that is already linked to the account.
class DuplicateProviderException extends AuthException {
  DuplicateProviderException() : super(message: 'The user is already linked to the supplied auth provider.');
}

class MissingProviderException extends AuthException {
  MissingProviderException() : super(message: 'The user is not linked with the required auth provider.');
}

/// Thrown when attempting to login, register, or update a username to an invalid email.
class InvalidUsernameException extends AuthException {
  InvalidUsernameException() : super(message: 'The username is invalid.');
}

/// Thrown when attempting to login, register, or update a password to an invalid or weak password.
class InvalidPasswordException extends AuthException {
  InvalidPasswordException() : super(message: 'The password is invalid.');
}

/// Thrown when attempting to log in with a invalid credential. This is distinct from a valid credential with the wrong values.
class InvalidCredentialException extends AuthException {
  InvalidCredentialException() : super(message: 'The credential is malformed or expired.');
}

/// Thrown when attempting to authenticate with a valid credential that does not match the stored credentials.
class WrongPasswordException extends AuthException {
  WrongPasswordException() : super(message: 'The supplied password does not match the stored password.');
}

/// Thrown when attempting to authenticate with a disabled account.
class DisabledUserException extends AuthException {
  DisabledUserException() : super(message: 'The user is disabled.');
}

/// Thrown when attempting to authenticate with an email that has no associated account.
class MissingUserException extends AuthException {
  MissingUserException() : super(message: 'The user was not found.');
}

/// Thrown when attempting to reauthenticate with a credential for a different user.
class MismatchedUserException extends AuthException {
  MismatchedUserException() : super(message: 'The credential is for a different user.');
}

/// Thrown when attempting an operation that requires recent authentication, like changing a password.
class StaleAuthenticationException extends AuthException {
  StaleAuthenticationException() : super(message: 'The operation requires a recent login.');
}

/// Thrown when a user cancels a federated authentication flow, like signing in with Google or Apple.
class CancelledAuthenticationException extends AuthException {
  CancelledAuthenticationException() : super(message: 'The federated authentication flow was cancelled.');
}

/// Thrown when attempting an operation that is disabled by the project.
class InvalidOperationException extends AuthException {
  InvalidOperationException() : super(message: 'That operation is invalid.');
}

extension AuthExceptionExtension on FirebaseAuthException {
  AuthException toAuthException() {
    if (code == 'account-exists-different-credential') return DuplicateUsernameException();
    if (code == 'email-already-in-use') return DuplicateUsernameException();
    if (code == 'invalid-email') throw InvalidUsernameException();
    if (code == 'invalid-credential') return InvalidCredentialException();
    if (code == 'wrong-password') return WrongPasswordException();
    if (code == 'weak-password') return InvalidPasswordException();
    if (code == 'user-not-found') return MissingUserException();
    if (code == 'user-disabled') return DisabledUserException();
    if (code == 'user-mismatch') return MismatchedUserException();
    if (code == 'requires-recent-login') return StaleAuthenticationException();
    if (code == 'operation-not-allowed') return InvalidOperationException();

    return AuthException(message: 'Unknown FirebaseAuthException code', code: code);
  }
}
