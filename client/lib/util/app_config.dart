import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'app_channel.dart';
import 'logger.dart';

enum Environment { development, production }
enum BuildMode { debug, profile, release }

class AppConfig extends InheritedWidget {
  AppConfig({
    @required this.name,
    @required this.environment,
    @required Widget child,
  }) : super(child: child);

  final String name;
  final Environment environment;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;

  BuildMode get buildmode {
    if (kReleaseMode) return BuildMode.release;
    if (kProfileMode) return BuildMode.profile;
    return BuildMode.debug;
  }

  @override
  bool updateShouldNotify(InheritedWidget widget) => false;
}

Future<Environment> getEnvironmentFromBuildFlavor() async {
  try {
    WidgetsFlutterBinding.ensureInitialized(); // explicitly call this in case `runApp` has not been called yet
    final flavor = await const AppChannel('flavor').invokeMethod<String>('get');
    logger.d('Received application flavor "$flavor" from native channel.');
    return (flavor == 'production') ? Environment.production : Environment.development;
  } on Exception {
    logger.e('Unable to load application flavor.');
    return Environment.development;
  }
}
