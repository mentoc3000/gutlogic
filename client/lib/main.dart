import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import 'auth/auth.dart';
import 'blocs/gut_logic_bloc_observer.dart';
import 'resources/firebase/analytics_service.dart';
import 'resources/firebase/crashlytics_service.dart';
import 'resources/firebase/remote_config_service.dart';
import 'resources/user_repository.dart';
import 'routes/routes.dart';
import 'util/app_config.dart';
import 'util/logger.dart';
import 'widgets/app.dart';

void main() async {
  // Fixes issues with using native channels before calling runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app config.
  final config = await AppConfig.create();

  // Enable debug logs for development or debug builds.
  final showDebugLogs = config.isDevelopment || config.isDebug;
  Logger.level = showDebugLogs ? Level.debug : Level.error;
  EquatableConfig.stringify = showDebugLogs;

  // Initialize the default Firebase app for all dependencies.
  final firebase = await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  logger.i('Initialized Firebase project ${firebase.options.projectId}');

  // TODO: prompt users to opt in, save to user profile
  // check with analytics database:
  // https://github.com/FirebaseExtended/flutterfire/blob/1daaea78dcb61d423444fccc2238db27bf7d281e/packages/firebase_analytics/firebase_analytics/lib/firebase_analytics.dart#L50

  final analytics = AnalyticsService(enabled: true);

  // Set `enableInDevMode` to true to see reports while in debug mode. This is only to be used for confirming that
  // reports are being submitted as expected. It is not intended to be used for everyday development.

  final crashlytics = await CrashlyticsService.initialize(enabled: config.isRelease);

  // Create and initialize [RemoteConfigService] in load screen
  // https://firebase.google.com/docs/remote-config/loading

  final remoteConfigService = await RemoteConfigService.initialize(enabled: config.isProduction);

  // Forward flutter errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) async {
    await crashlytics.recordFlutterError(details);
    FlutterError.presentError(details);
  };

  // Observe bloc transitions, report some things automatically to analytics/crashlytics.
  Bloc.observer = GutLogicBlocObserver(analytics: analytics, crashlytics: crashlytics);

  final users = UserRepository();

  final app = MultiProvider(providers: [
    Provider.value(value: config),
    Provider.value(value: analytics),
    Provider.value(value: crashlytics),
    Provider.value(value: remoteConfigService),
    Provider.value(value: users),
    ...(await AuthService.providers(config: config)),
    Provider(create: (_) => Routes()),
  ], child: GutLogicApp());

  // Forward zone errors to Crashlytics.
  runZonedGuarded(() => runApp(app), (error, trace) => unawaited(crashlytics.record(error, trace)));
}
