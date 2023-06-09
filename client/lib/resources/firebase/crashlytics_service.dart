import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  /// Create and initialize the crashlytics service.
  static Future<CrashlyticsService> initialize({bool enabled = true}) async {
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(enabled);
    return CrashlyticsService._(crashlytics);
  }

  CrashlyticsService._(FirebaseCrashlytics crashlytics) : _crashlytics = crashlytics;

  Future<void> record(dynamic error, StackTrace trace, {bool fatal = false}) =>
      _crashlytics.recordError(error, trace, fatal: fatal);

  Future<void> recordFlutterError(FlutterErrorDetails details) => _crashlytics.recordFlutterError(details);

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) => _crashlytics.recordFlutterFatalError(details);
}
