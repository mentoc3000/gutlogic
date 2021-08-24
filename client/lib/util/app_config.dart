import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_channel.dart';
import 'logger.dart';

enum Environment { development, production }

extension EnvironmentExtensions on Environment {
  String get name => this == Environment.development ? 'dev' : 'prod';
}

/// The type of build (debug, profile, or release).
enum Build { debug, profile, release }

class AppConfig {
  AppConfig({
    required this.version,
    required this.environment,
  });

  /// The application version (as defined in pubspec.yaml).
  final String version;

  /// The overall application environment.
  final Environment environment;

  /// True if the environment is a development environment.
  bool get isDevelopment => environment == Environment.development;

  /// True if the environment is a production environment.
  bool get isProduction => environment == Environment.production;

  /// True if the build is a release or profile build.
  bool get isRelease => build == Build.release || build == Build.profile;

  /// True if the build is a debug build.
  bool get isDebug => build == Build.debug;

  /// The build variant.
  Build get build {
    if (kReleaseMode) return Build.release;
    if (kProfileMode) return Build.profile;
    return Build.debug;
  }

  static Future<AppConfig> create() async {
    var environment = Environment.development;

    try {
      WidgetsFlutterBinding.ensureInitialized(); // explicitly call this in case `runApp` has not been called yet
      final flavor = await const AppChannel('flavor').invokeMethod<String>('get');
      logger.d('Received application flavor "$flavor" from native channel.');
      environment = (flavor == 'production') ? Environment.production : Environment.development;
    } on Exception {
      logger.e('Unable to load application flavor.');
    }

    final version = (await PackageInfo.fromPlatform()).version;

    return AppConfig(
      version: version,
      environment: environment,
    );
  }
}
