import 'package:flutter/foundation.dart';
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
    required this.package,
    required this.environment,
  });

  /// The application package identifier.
  final String package;

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
    final info = await PackageInfo.fromPlatform();

    final version = info.version;
    final package = info.packageName;
    final environment = await _findApplicationEnvironment();

    return AppConfig(version: version, package: package, environment: environment);
  }

  static Future<Environment> _findApplicationEnvironment() async {
    const channel = AppChannel('flavor');

    try {
      final flavor = await channel.invokeMethod<String>('get');
      return (flavor == 'production') ? Environment.production : Environment.development;
    } on Exception {
      logger.e('Unable to load application flavor.');
    }

    return Environment.development;
  }
}
