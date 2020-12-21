import 'dart:async';
import 'package:meta/meta.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../util/logger.dart';

class RemoteConfigService {
  final RemoteConfig _remoteConfig;
  static const Duration initializationTimeout = Duration(seconds: 5);

  RemoteConfigService._({@required RemoteConfig remoteConfig, @required bool debugMode}) : _remoteConfig = remoteConfig;

  static Future<RemoteConfigService> createAndInitialize({bool debugMode = false}) async {
    final remoteConfig = await RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: debugMode));
    // Defaults are not set here, but provided in the [_RemoteConfiguration]
    final remoteConfigService = RemoteConfigService._(remoteConfig: remoteConfig, debugMode: debugMode);
    await remoteConfigService._initialize();
    return remoteConfigService;
  }

  /// Fetch latest remote config values and activate them.
  Future<void> _initialize() async {
    try {
      await _fetchAndActivate().timeout(initializationTimeout);
    } on FetchThrottledException catch (exception) {
      logger.w('Remote config fetch throttled: $exception');
    } on TimeoutException catch (exception) {
      logger.w('Fetch and activate timed out: $exception');
    } catch (exception) {
      logger.e('''Unable to fetch remote config: $exception
      Cached or default values will be used.
      ''');
    }
  }

  Future<void> _fetchAndActivate() async {
    await _remoteConfig.fetch();
    await _remoteConfig.activateFetched();
  }

  T get<T>(RemoteConfiguration<T> configuration) {
    final remoteConfigValue = _remoteConfig.getValue(configuration.key);
    logger.i('RemoteConfigService: ${configuration.key} retrieved from ${remoteConfigValue.source}');

    if (remoteConfigValue.source != ValueSource.valueRemote) {
      return configuration.defaultValue;
    }

    if (T == String) {
      return remoteConfigValue.asString() as T;
    }
    if (T == bool) {
      return remoteConfigValue.asBool() as T;
    }
    if (T == int) {
      return remoteConfigValue.asInt() as T;
    }
    if (T == double) {
      return remoteConfigValue.asDouble() as T;
    }

    throw TypeError();
  }
}

class RemoteConfiguration<T> {
  final String key;
  final T defaultValue;

  RemoteConfiguration({@required this.key, @required this.defaultValue})
      : assert(T == bool || T == int || T == double || T == String);
}
