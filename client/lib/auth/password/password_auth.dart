import 'package:firebase_auth/firebase_auth.dart';

import '../auth_provider.dart';
import '../auth_result.dart';

class PasswordAuth {
  Future<AuthResult> authenticate({required String username, required String password}) async {
    final cred = EmailAuthProvider.credential(email: username, password: password);
    return AuthResult(provider: AuthProvider.password, email: username, credential: cred);
  }

  Future<void> deauthenticate() async {
    return;
  }
}
