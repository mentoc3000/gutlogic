import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../util/result.dart';
import '../auth.dart';

/// Creates auth tokens from "Sign in with Google" integration.
class GoogleAuthService implements AuthProviderService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  FutureResult<Authentication> authenticate() async {
    try {
      final googleSignInUser = await _googleSignIn.signIn();

      if (googleSignInUser == null) return Result.error(CancelledAuthenticationException());

      final auth = await googleSignInUser.authentication;
      final cred = firebase_auth.GoogleAuthProvider.credential(idToken: auth.idToken, accessToken: auth.accessToken);

      return Result.value(Authentication(
        method: AuthMethod.google,
        provider: AuthProvider.google,
        email: googleSignInUser.email,
        credential: cred,
      ));
    } catch (ex) {
      return Result.error(ex);
    }
  }

  @override
  Future<void> deauthenticate() async {
    await _googleSignIn.signOut();
  }
}
