import 'dart:async';
import 'dart:io';

import 'screenshots_process.dart';

Future<List<AndroidDevice>> devices() async {
  final result = await run('emulator', ['-list-avds']);
  final lines = (result.stdout as String).split('\n');
  return lines.where((element) => element.isNotEmpty).map((e) => AndroidDevice.fromString(e)).toList();
}

Future<List<AndroidEmulator>> emulators() async {
  final emulatorNamesResult = await run('adb', ['devices']);
  final emulatorNames = (emulatorNamesResult.stdout as String)
      .split('\n')
      .where((element) => element.startsWith('emulator'))
      .map((e) => e.split('\t').first);
  return Future.wait(emulatorNames.map(emulator));
}

Future<AndroidEmulator> emulator(String emulatorName) async {
  final result = await run('adb', ['-s', emulatorName, 'shell', 'getprop']);
  final avdNameMatcher = RegExp(r'\[ro\.boot\.qemu\.avd_name\]\: \[(\w*)\]');
  final avdName = avdNameMatcher.firstMatch(result.stdout as String)?[1];
  return AndroidEmulator(
    device: AndroidDevice.fromString(avdName!),
    id: emulatorName,
  );
}

Future<void> launch(AndroidDevice device) async {
  // emulator must be run from its directory so Qt can be correctly found
  // https://stackoverflow.com/questions/42554337/cannot-launch-avd-in-emulatorqt-library-not-found
  final path = await run('which', ['emulator']);
  final file = File(path.stdout as String);
  unawaited(runDetached('emulator', ['-avd', device.avdName], workingDirectory: file.parent.path));
}

Future<void> close(AndroidEmulator handle) async {
  await run('adb', ['-s', handle.id, 'emu', 'kill']);
}

Future<void> closeAll() async {
  try {
    await run('adb', ['emu', 'kill']);
    await Future.delayed(const Duration(seconds: 10));
  } catch (e) {}
}

class AndroidDevice {
  final String device;
  final String api;
  String get avdName => '${device.replaceAll(" ", "_")}_API_${api.replaceAll(" ", "_")}';

  const AndroidDevice({
    required this.device,
    required this.api,
  });

  factory AndroidDevice.fromString(String s) {
    final words = s.split('_');
    final api = words.last;
    final name = words.getRange(0, words.length - 2).join(' ');
    return AndroidDevice(device: name, api: api);
  }

  @override
  String toString() => '$device (API $api)';
}

/// An instance of [AndroidDevice]
class AndroidEmulator {
  final AndroidDevice device;
  final String id;

  const AndroidEmulator({
    required this.device,
    required this.id,
  });

  @override
  String toString() => '${device.toString()} [$id]';
}
