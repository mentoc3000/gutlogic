import 'dart:collection';
import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;

class ScreenshotsConfig {
  /// A list of requested locales.
  final UnmodifiableListView<String> locales;

  /// A list of requested iOS device names.
  final UnmodifiableListView<String> ios;

  /// A list of requested Android device names.
  final UnmodifiableListView<String> android;

  ScreenshotsConfig({required List<String> locales, required List<String> android, required List<String> ios})
      : locales = UnmodifiableListView(locales),
        android = UnmodifiableListView(android),
        ios = UnmodifiableListView(ios);

  /// Load the ScreenshotsConfig from a YAML file at [path] relative to the CWD.
  static Future<ScreenshotsConfig> load(String path) async {
    final configData = await File(path).readAsString();
    final configYAML = yaml.loadYaml(configData);

    final locales = List<String>.from(configYAML['locales'] ?? ['en-US']);
    final android = List<String>.from(configYAML['devices']['android'] ?? []);
    final ios = List<String>.from(configYAML['devices']['ios'] ?? []);

    return ScreenshotsConfig(locales: locales, android: android, ios: ios);
  }
}
