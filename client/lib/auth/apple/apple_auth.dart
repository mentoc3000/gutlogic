import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../util/app_channel.dart';
import '../auth.dart';
import '../auth_platform.dart';
import '../auth_provider.dart';
import '../auth_result.dart';
import '../auth_utils.dart';

class AppleAuth implements AuthPlatform {
  static final OAuthProvider _oauth = OAuthProvider('apple.com');
  static const AppleAuthChannel _channel = AppleAuthChannel();

  static bool _cachedAvailabilityChecked = false;
  static bool _cachedAvailability = false;

  /// Apple authentication is only available on or after iOS 13.0. Returns [True] if authentication is available.
  static bool get available {
    if (_cachedAvailabilityChecked == false) {
      throw 'Apple authentication availability has not been checked yet. Call `queryAndCacheAvailability` first.';
    }

    return _cachedAvailability;
  }

  /// Asynchronously query and cache the availability of Apple authentication on this platform.
  static Future<void> queryAndCacheAvailability() async {
    if (_cachedAvailabilityChecked == false) {
      _cachedAvailability = await _channel.invokeMethod<bool>('available');
      _cachedAvailabilityChecked = true;
    }
  }

  /// Returns the credential state of an Apple ID user.
  // Future<AppleIDCredentialState> _getCredentialState(String userID) async {
  //   final result = await _channel.invokeMethod('getCredentialState', {'user_id', userID});
  //
  //   switch (result) {
  //     case 'authorized':
  //       return AppleIDCredentialState.authorized;
  //     case 'revoked':
  //       return AppleIDCredentialState.revoked;
  //   }
  //
  //   return AppleIDCredentialState.unknown;
  // }

  @override
  Future<AuthResult> authenticate() async {
    if (available == false) throw 'Sign in with Apple is not available on this platform.';

    final rawNonce = generateOAuthNonce();
    final encNonce = encryptOAuthNonce(rawNonce);

    Map<String, String> result;

    try {
      // TODO can we do this silently?
      result = await _channel.invokeMapMethod<String, String>('authenticate', {'nonce': encNonce});
    } on PlatformException catch (ex) {
      if (ex.code == 'AUTHORIZATION_ERROR/CANCELED') {
        throw CancelledAuthenticationException();
      } else {
        rethrow;
      }
    }

    // The authentication result has many keys, some of which are only filled the first time the user authenticates:
    //
    // state        - ?
    // nonce        - The raw nonce string submitted for the credential, which we pass to OAuthProvider to verify the
    //                identity and access tokens.
    // email        - The email associated with the credential. This could be the Apple ID email, or an anonymous
    //                forwarding email.Only returned the first time the user authenticates.
    // user_id      - A user ID that we can reuse to get new information.
    // short_name   - The nickname associated with the account. Only returned on the first authentication.
    // given_name   - The first name associated with the account. Only returned on the first authentication.
    // family_name  - The last name associated with the account. Only returned on the first authentication.
    // id_token     - A string we can pass to the OAuthProvider to get a Firebase credential.
    // access_token - A string we can pass to the OAuthProvider to get a Firebase credential.

    // TODO cache the name so we can use it later

    assert(result.containsKey('id_token'));
    assert(result.containsKey('access_token'));

    final cred = _oauth.credential(
      rawNonce: rawNonce,
      idToken: result['id_token'],
      accessToken: result['access_token'],
    );

    return AuthResult(provider: AuthProvider.apple, email: result['email'], credential: cred);
  }

  @override
  Future<void> deauthenticate() async {
    if (available == false) return;

    await _channel.invokeMethod('deauthenticate');
  }
}

enum AppleIDCredentialState {
  authorized,
  revoked,
  unknown,
}

class AppleAuthChannel extends AppChannel {
  const AppleAuthChannel() : super('apple');
}
