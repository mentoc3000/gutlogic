/// Each AuthProvider is a method of providing authentication. Each user has at least one, but possibly several,
/// providers associated with their account.
enum AuthProvider {
  firebase,
  password,
  google,
  apple,
}

/// Converts an AuthProvider [value] to a firebase_auth provider ID.
String toFirebaseProviderID(AuthProvider value) {
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
AuthProvider fromFirebaseProviderID(String value) {
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

  throw ArgumentError('Unknown Firebase provider value $value');
}
