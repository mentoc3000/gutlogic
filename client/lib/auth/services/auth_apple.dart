import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';

import '../../../util/app_channel.dart';
import '../../util/result.dart';
import '../auth_data.dart';
import '../auth_service.dart';
import '../auth_util.dart';

/// Creates auth tokens from Apple integration.
class AppleAuthService implements AuthProviderService {
  static final firebase_auth.OAuthProvider _oauth = firebase_auth.OAuthProvider('apple.com');
  static const AppChannel _channel = AppChannel('apple');

  /// Returns the availability of Apple authentication on this platform.
  static Future<bool> available() async {
    try {
      return await _channel.invokeMethod<bool>('available') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  FutureResult<Authentication> authenticate() async {
    try {
      final rawNonce = generateOAuthNonce();
      final encNonce = encryptOAuthNonce(rawNonce);

      final result = await _channel.invokeMapMethod<String, String>('authenticate', {'nonce': encNonce}) ?? {};

      // See AppleAuthChannel.swift AppleAuthRequestController#resolveAppleIDCredential for result structure.

      assert(result.containsKey('id_token'));
      assert(result.containsKey('access_token'));

      final cred = _oauth.credential(
        rawNonce: rawNonce,
        idToken: result['id_token'],
        accessToken: result['access_token'],
      );

      return Result.value(Authentication(
        method: AuthMethod.apple,
        email: result['email'],
        credential: cred,
      ));
    } catch (ex) {
      return Result.error(ex);
    }
  }

  @override
  Future<void> deauthenticate() async {
    await _channel.invokeMethod('deauthenticate');
  }
}

enum AppleIDCredentialState {
  authorized,
  revoked,
  unknown,
}
