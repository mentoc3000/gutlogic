import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../auth_data.dart';
import '../auth_exception.dart';

/// Creates auth tokens via email links.
class EmailAuthService {
  final String _package;
  late final String _url;
  late final Stream<String> _links;

  /// Create the email auth service with the specified app [package] identifier and dynamic [url].
  EmailAuthService({required String url, required String package})
      : _url = url,
        _package = package {
    _links = FirebaseDynamicLinks.instance.onLink
        .map((data) => data.link.toString())
        .where(FirebaseAuth.instance.isSignInWithEmailLink);
  }

  /// Send an authentication link to [email].
  ///
  /// Throws an [InvalidEmailException] if the email is invalid.
  Future<void> sendAuthenticationLink(String email) async {
    try {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: _url,
          iOSBundleId: _package,
          androidPackageName: _package,
          androidMinimumVersion: '0',
          handleCodeInApp: true,
        ),
      );
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }
  }

  /// Return an authentication stream by combining the specified [email] with the dynamic links passed to the app.
  ///
  /// There is no way to ensure that any particular link is for the specified [email] without attempting to sign in.
  /// If an auth link was previously sent to email A and this stream was created for email B, opening the auth link
  /// from email A will emit an invalid Authentication object from this stream which the consumer should anticipate.
  Stream<Authentication> streamAuthenticationForEmail(String email) {
    return _links.map((link) {
      final cred = EmailAuthProvider.credentialWithLink(email: email, emailLink: link);
      return Authentication(
        method: AuthMethod.email,
        provider: AuthProvider.firebase,
        credential: cred,
        email: email,
      );
    });
  }
}
