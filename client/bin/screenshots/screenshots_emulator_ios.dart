import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:quiver/iterables.dart';

import 'screenshots_process.dart';

/// Open the Apple Simulator, which happens independantly from booting individual devices.
Future<void> openAppleSimulator() async {
  await run('open', ['/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/']);
}

/// Launch an Apple Simulator with the provided config.
Future<void> launch(AppleSimulatorDevice device) async {
  await run('xcrun', ['simctl', 'bootstatus', device.udid, '-b']);
}

/// Close an Apple Simulator using a [handle] returned by launch.
Future<void> close(AppleSimulatorDevice device) async {
  await run('xcrun', ['simctl', 'shutdown', device.udid]);
}

/// Returns a list of available Apple Simulator devices.
Future<List<AppleSimulatorDevice>> devices() async {
  final result = await run('xcrun', ['simctl', 'list', 'devices', 'available', '-j']);

  // Decode the xcrun data (requested as JSON).
  final data = json.decode(result.stdout as String);

  // Get the device groups, which are lists of devices keyed by runtime.
  final groups = (data['devices'] as Map).entries;

  // Map the device groups into a flat list of simulator configs.
  final configs = concat(groups.map((entry) {
    final deviceRuntimeRegExp = RegExp(r'com\.apple\.CoreSimulator\.SimRuntime\.(\w+)-(\d+)-(\d+)');

    final match = deviceRuntimeRegExp.firstMatch(entry.key);

    if (match == null) return [];

    final runtimePlatformName = match.group(1);
    final runtimeMajorVersion = int.parse(match.group(2));
    final runtimeMinorVersion = int.parse(match.group(3));

    final platform = AppleSimulatorPlatform(runtimePlatformName);
    final version = AppleSimulatorVersion(runtimeMajorVersion, runtimeMinorVersion);

    return entry.value.map((device) {
      final deviceName = device['name'] as String;
      final deviceUDID = device['udid'] as String;
      return AppleSimulatorDevice(udid: deviceUDID, name: deviceName, platform: platform, version: version);
    });
  }));

  return List<AppleSimulatorDevice>.from(configs);
}

class AppleSimulatorDevice {
  final String udid;
  final String name;
  final AppleSimulatorVersion version;
  final AppleSimulatorPlatform platform;

  const AppleSimulatorDevice({
    @required this.udid,
    @required this.name,
    @required this.platform,
    @required this.version,
  });

  @override
  String toString() => '$name ($platform $version) [$udid]';
}

class AppleSimulatorPlatform {
  final String name;

  const AppleSimulatorPlatform(this.name);

  static const iOS = AppleSimulatorPlatform('iOS');
  static const tvOS = AppleSimulatorPlatform('tvOS');
  static const watchOS = AppleSimulatorPlatform('watchOS');

  @override
  String toString() => name;
}

class AppleSimulatorVersion {
  final int major;
  final int minor;

  const AppleSimulatorVersion(this.major, this.minor);

  @override
  String toString() => '$major.$minor';
}
