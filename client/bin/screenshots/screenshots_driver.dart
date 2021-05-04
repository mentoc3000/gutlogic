import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_driver/flutter_driver.dart';

import 'screenshots_process.dart';
import 'screenshots_util.dart';

/// A function which orchestrates the screenshot driving and decides when to capture screenshots.
typedef ScreenshotsDriver = Future<void> Function(FlutterDriver driver, CaptureDelegate capture);

/// A function passed to the ScreenshotDriver which captures and saves a screenshot.
typedef CaptureDelegate = Future<void> Function(String name);

/// Runs a function in a driver context with a delegate for capturing screenshots.
void screenshots(ScreenshotsDriver run) async {
  final driver = await FlutterDriver.connect();

  final health = await driver.checkHealth();

  assert(health.status == HealthStatus.ok, 'Flutter driver failed to connect.');

  final platform = await driver.requestData(requestPlatformMessage);
  final device = await driver.requestData(requestDeviceNameMessage);
  final locale = await driver.requestData(requestLocaleNameMessage);

  assert(device.isNotEmpty, 'Flutter driver failed to return a device name.');

  await run(driver, (name) async {
    await driver.waitUntilNoTransientCallbacks(timeout: const Duration(seconds: 10));
    await _capture(_path(platform, locale, '$device ($locale) $name.png'), device);
  });

  await driver.close();
}

/// Returns the path of a screenshot for a given [platform] (e.g. ios/android) and [locale].
String _path(String platform, String locale, String filename) {
  if (platform == 'android') {
    return 'android/fastlane/$locale/images/phonescreenshots/$filename';
  }

  if (platform == 'ios') {
    return 'ios/fastlane/screenshots/$locale/$filename';
  }

  throw ArgumentError('Unknown platform $platform');
}

/// Save a screenshot from the device associated with [deviceID] to [path].
///
/// Originally this used `driver.screenshot()` which is much faster. Unfortunately it only captures the Flutter widget
/// contents and none of the system UI. Instead we run `flutter screenshot` as a child process for each screenshot,
/// which is slow but successfully screenshots the entire system UI. If the same functionality is ever exposed on the
/// driver or daemon we should update this function to the alternative.
Future<void> _capture(String path, String deviceID) async {
  await File(path).create(recursive: true);
  await run('flutter', ['screenshot', '--device-id=$deviceID', '--out=$path']);
}
