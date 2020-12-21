import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth.dart';
import '../auth_platform.dart';
import '../auth_provider.dart';
import '../auth_result.dart';

class GoogleAuth implements AuthPlatform {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<AuthResult> authenticate() async {
    final user = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

    // This can happen if the user taps off the auth flow midway through.
    if (user == null) throw CancelledAuthenticationException();

    final auth = await user.authentication;

    final cred = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );

    return AuthResult(provider: AuthProvider.google, email: user.email, credential: cred);
  }

  @override
  Future<void> deauthenticate() async {
    await _googleSignIn.signOut();
  }
}
