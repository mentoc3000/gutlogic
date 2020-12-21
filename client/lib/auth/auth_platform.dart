import 'auth_result.dart';

abstract class AuthPlatform {
  /// Authenticate the auth platform.
  Future<AuthResult> authenticate();

  /// Deauthenticate the auth platform.
  Future<void> deauthenticate();
}
