import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// A method of authentication. Some services have multiple services of authentication (eg Firebase uses links, passwords, etc).
enum AuthMethod { email, google, apple, anonymous }

/// A source of authentication.
enum AuthProvider { firebase, password, google, apple }

abstract class AuthProviderUtil {
  /// Converts an AuthProvider [value] to a firebase_auth provider ID.
  static String toFirebaseProviderID(AuthProvider value) {
    switch (value) {
      case AuthProvider.firebase:
        return 'firebase';
      case AuthProvider.password:
        return 'password';
      case AuthProvider.google:
        return 'google.com';
      case AuthProvider.apple:
        return 'apple.com';
    }
  }

  /// Converts a firebase_auth provider ID to an AuthProvider value.
  static AuthProvider fromFirebaseProviderID(String value) {
    switch (value) {
      case 'firebase':
        return AuthProvider.firebase;
      case 'password':
        return AuthProvider.password;
      case 'google.com':
        return AuthProvider.google;
      case 'apple.com':
        return AuthProvider.apple;
    }

    throw ArgumentError('Unknown provider $value');
  }
}

/// An authentication that can be used to login to the app.
class Authentication extends Equatable {
  /// The authentication method.
  final AuthMethod method;

  /// The Firebase AuthCredential to use when logging in.
  final firebase_auth.AuthCredential credential;

  /// The email associated with the auth provider. This could be null for platforms that don't provide one.
  final String? email;

  const Authentication({required this.method, required this.credential, this.email});

  @override
  List<Object?> get props => [method, credential, email];
}
