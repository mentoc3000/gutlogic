import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../util/logger.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig? _remoteConfig;

  RemoteConfigService._(FirebaseRemoteConfig? remoteConfig) : _remoteConfig = remoteConfig;

  static Future<RemoteConfigService> initialize({bool enabled = true}) async {
    if (enabled == false) return RemoteConfigService._(null);

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 5),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    try {
      await remoteConfig.fetch();
      await remoteConfig.activate();
    } catch (exception) {
      logger.e('''Unable to fetch remote config: $exception
                  Cached or default values will be used.''');
    }

    // Defaults are embedded in the [RemoteConfiguration] passed to [get].
    return RemoteConfigService._(remoteConfig);
  }

  T get<T>(RemoteConfiguration<T> configuration) {
    if (_remoteConfig == null) return configuration.defaultValue;

    final remoteConfigValue = _remoteConfig!.getValue(configuration.key);

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

  RemoteConfiguration({
    required this.key,
    required this.defaultValue,
  }) : assert(T == bool || T == int || T == double || T == String);
}
