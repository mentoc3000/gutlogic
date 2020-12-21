import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pedantic/pedantic.dart';

import 'auth/apple/apple_auth.dart';
import 'resources/firebase/remote_config_service.dart';
import 'util/app_config.dart';
import 'util/logger.dart';
import 'widgets/app.dart';

void main() async {
  final env = await getEnvironmentFromBuildFlavor();

  // Initialize the default Firebase app for all dependencies.
  final firebaseApp = await Firebase.initializeApp();
  logger.i('Initialized Firebase project ${firebaseApp.options.projectId}');

  // Create and intialize [RemoteConfigService] in load screen
  // https://firebase.google.com/docs/remote-config/loading
  final remoteConfigService = await RemoteConfigService.createAndInitialize(debugMode: env == Environment.development);

  // Cache Sign in with Apple availability so it can be used synchronously.
  await AppleAuth.queryAndCacheAvailability();

  final app = AppConfig(
    name: env == Environment.development ? 'dev' : 'prod',
    environment: env,
    child: GutLogicApp(remoteConfigService: remoteConfigService),
  );

  // Log debug logs for dev/debug builds.
  final isDevelopment = env == Environment.development;
  final isDebug = app.buildmode == BuildMode.debug;
  Logger.level = isDevelopment || isDebug ? Level.debug : Level.error;

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  if (isDebug) {
    unawaited(FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false));
  }

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runZoned(() => runApp(app), onError: FirebaseCrashlytics.instance.recordError);
}
