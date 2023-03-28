import 'dart:collection';
import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;

class ScreenshotsConfig {
  /// A list of requested locales.
  final UnmodifiableListView<String> locales;

  /// A list of requested iOS device names.
  final UnmodifiableListView<String> ios;

  /// A list of requested Android device names.
  final UnmodifiableListView<AndroidConfig> android;

  ScreenshotsConfig({required List<String> locales, required List<AndroidConfig> android, required List<String> ios})
      : locales = UnmodifiableListView(locales),
        android = UnmodifiableListView(android),
        ios = UnmodifiableListView(ios);

  /// Load the ScreenshotsConfig from a YAML file at [path] relative to the CWD.
  static Future<ScreenshotsConfig> load(String path) async {
    final configData = await File(path).readAsString();
    final configYAML = yaml.loadYaml(configData);

    final locales = List<String>.from(configYAML['locales'] ?? ['en-US']);
    final android = ((configYAML['devices']['android'] ?? []) as List)
        .map((e) => AndroidConfig.fromMap((e as yaml.YamlMap).value))
        .toList();
    final ios = List<String>.from(configYAML['devices']['ios'] ?? []);

    return ScreenshotsConfig(locales: locales, android: android, ios: ios);
  }
}

class AndroidConfig {
  final String device;
  final int width;
  final List<String> sizes;

  const AndroidConfig({required this.device, required this.width, required this.sizes});

  factory AndroidConfig.fromMap(Map map) {
    return AndroidConfig(
      device: map['device'],
      width: map['width'],
      sizes: List<String>.from(map['sizes']),
    );
  }
}
