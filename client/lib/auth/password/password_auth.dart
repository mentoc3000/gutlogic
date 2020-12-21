import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../auth_platform.dart';
import '../auth_provider.dart';
import '../auth_result.dart';

class PasswordAuth implements AuthPlatform {
  @override
  Future<AuthResult> authenticate({@required String username, @required String password}) async {
    final cred = EmailAuthProvider.credential(email: username, password: password);
    return AuthResult(provider: AuthProvider.password, email: username, credential: cred);
  }

  @override
  Future<void> deauthenticate() async {
    return;
  }
}
