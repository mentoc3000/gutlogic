// ignore_for_file: avoid_print

import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;

/// Prints the local pubspec.yaml version.
void main() async {
  final pubspecData = await File('pubspec.yaml').readAsString();
  final pubspecYAML = yaml.loadYaml(pubspecData);
  print(pubspecYAML['version']);
}
