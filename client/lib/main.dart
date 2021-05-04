import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pedantic/pedantic.dart';

import 'auth/apple/apple_auth.dart';
import 'resources/firebase/analytics_service.dart';
import 'resources/firebase/crashlytics_service.dart';
import 'resources/firebase/remote_config_service.dart';
import 'util/app_config.dart';
import 'util/logger.dart';
import 'widgets/app.dart';

void main() async {
  final env = await AppConfig.lookupEnvironment();
  final build = await AppConfig.lookupBuildMode();

  final isDevelopment = env == Environment.development;
  final isDebug = build == BuildMode.debug;

  // Initialize the default Firebase app for all dependencies.
  final firebase = await Firebase.initializeApp();

  logger.i('Initialized Firebase project ${firebase.options.projectId}');

  // TODO: prompt users to opt in, save to user profile
  // check with analytics database:
  // https://github.com/FirebaseExtended/flutterfire/blob/1daaea78dcb61d423444fccc2238db27bf7d281e/packages/firebase_analytics/firebase_analytics/lib/firebase_analytics.dart#L50

  final analytics = AnalyticsService(enabled: true);

  // Set `enableInDevMode` to true to see reports while in debug mode. This is only to be used for confirming that
  // reports are being submitted as expected. It is not intended to be used for everyday development.

  final crashlytics = await CrashlyticsService.initialize(enabled: !isDebug);

  // Create and initialize [RemoteConfigService] in load screen
  // https://firebase.google.com/docs/remote-config/loading

  final remoteConfigService = await RemoteConfigService.initialize(enabled: !isDevelopment);

  final app = AppConfig(
    name: env == Environment.development ? 'dev' : 'prod',
    environment: env,
    child: GutLogicApp(
      analytics: analytics,
      crashlytics: crashlytics,
      remoteConfigService: remoteConfigService,
    ),
  );

  // Enable debug logs for development or debug builds.
  Logger.level = (isDevelopment || isDebug) ? Level.debug : Level.error;

  // Cache Sign in with Apple availability so it can be used synchronously.
  await AppleAuth.queryAndCacheAvailability();

  // Forward flutter errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) async {
    await crashlytics.recordFlutterError(details);
    FlutterError.presentError(details);
  };

  // Forward zone errors to Crashlytics.
  runZonedGuarded(() => runApp(app), (error, trace) => unawaited(crashlytics.record(error, trace)));
}
