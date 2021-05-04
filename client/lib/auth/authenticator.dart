import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'apple/apple_auth.dart';
import 'auth_provider.dart';
import 'auth_result.dart';
import 'google/google_auth.dart';
import 'password/password_auth.dart';

/// An authenticator abstracts the various ways of authenticating (Google, Apple, etc).
class Authenticator {
  /// Find a provided Authenticator in the widget tree.
  static Authenticator of(BuildContext context) {
    return RepositoryProvider.of<Authenticator>(context);
  }

  /// Create a new RepositoryProvider widget for the Authenticator.
  static RepositoryProvider<Authenticator> provider() {
    return RepositoryProvider<Authenticator>(create: (context) => Authenticator());
  }

  final PasswordAuth _passwordAuth = PasswordAuth();
  final GoogleAuth _googleAuth = GoogleAuth();
  final AppleAuth _appleAuth = AppleAuth();

  /// Authenticate with a provider.
  ///
  /// Throws an [ArgumentError] if the [provider] cannot create credentials. Only the password, google, and apple auth
  /// providers are supported. Throws an [ArgumentError] if the password [provider] is passed without a [username] and
  /// [password].
  Future<AuthResult> authenticate({required AuthProvider provider, String? username, String? password}) {
    switch (provider) {
      case AuthProvider.password:
        if (username == null || password == null) throw ArgumentError('A username and password are required.');
        return _passwordAuth.authenticate(username: username, password: password);
      case AuthProvider.google:
        return _googleAuth.authenticate();
      case AuthProvider.apple:
        return _appleAuth.authenticate();
      default:
        // AuthProvider.firebase is not included because it cannot create credentials.
        throw ArgumentError('There is no credential provider for the auth provider $provider.');
    }
  }

  /// Deauthenticate with all providers.
  Future<void> deauthenticate() {
    return Future.wait([
      _passwordAuth.deauthenticate(),
      _googleAuth.deauthenticate(),
      _appleAuth.deauthenticate(),
    ]);
  }
}
