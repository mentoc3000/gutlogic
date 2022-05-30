import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/app_config.dart';
import '../util/result.dart';
import 'auth_data.dart';
import 'services/auth_apple.dart';
import 'services/auth_email.dart';
import 'services/auth_google.dart';

abstract class AuthService {
  static Future<List<Provider<dynamic>>> providers({required AppConfig config}) async {
    // TODO these might be better stored in some build config?
    const prodEmailAuthUrl = 'https://app.gutlogic.co/email_auth';
    const devEmailAuthUrl = 'https://gutlogicdev.page.link/email_auth';
    final emailAuthUrl = config.isProduction ? prodEmailAuthUrl : devEmailAuthUrl;

    return [
      if (await AppleAuthService.available()) Provider<AppleAuthService>(create: (c) => AppleAuthService()),
      Provider<EmailAuthService>(create: (c) => EmailAuthService(url: emailAuthUrl, package: config.package)),
      Provider<GoogleAuthService>(create: (c) => GoogleAuthService()),
    ];
  }

  /// Deauthenticate all of the auth services in the context.
  static Future<void> deauthenticate(BuildContext context) async {
    final appleAuthService = context.read<AppleAuthService?>();
    final googleAuthService = context.read<GoogleAuthService?>();

    await Future.wait([
      if (appleAuthService != null) appleAuthService.deauthenticate(),
      if (googleAuthService != null) googleAuthService.deauthenticate(),
    ]);
  }
}

abstract class AuthProviderService {
  FutureResult<Authentication> authenticate();
  Future<void> deauthenticate();
}
