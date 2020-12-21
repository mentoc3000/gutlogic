import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import 'auth_provider.dart';

class AuthResult {
  /// The AuthProvider this credential is for.
  final AuthProvider provider;

  /// The Firebase AuthCredential to use when logging in.
  final AuthCredential credential;

  /// The username associated with the auth provider. This could be null for platforms that don't provide one.
  final String email;

  AuthResult({@required this.provider, @required this.credential, this.email});
}
