import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:integration_test/integration_test.dart';

/// Runs a function in a driver context with a delegate for capturing screenshots.
Future<void> capture(IntegrationTestWidgetsFlutterBinding binding, String name) async {
  var deviceInfo = DeviceInfoPlugin();
  final platform = Platform.isIOS ? 'ios' : 'android';
  final locale = 'en-US'; // TODO: how to get locale without BuildContext?
  final device = await _getDevice(deviceInfo);
  final path = _path(platform, locale, '$device ($locale) $name.png');

  await binding.takeScreenshot(path);
}

/// Returns the path of a screenshot for a given [platform] (e.g. ios/android) and [locale].
String _path(String platform, String locale, String filename) {
  if (platform == 'android') {
    // This location just contains the images captured from Flutter. They must be resized and moved to their appropriate
    // directories (phoneScreenshots, sevenInchScreenshots, and tenInchScreenshots) for upload to Google Play Store.
    return 'android/fastlane/metadata/android/$locale/images/flutterShot/$filename';
  }

  if (platform == 'ios') {
    return 'ios/fastlane/screenshots/$locale/$filename';
  }

  throw ArgumentError('Unknown platform $platform');
}

Future<String?> _getDevice(DeviceInfoPlugin deviceInfo) async {
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.name;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return '${androidDeviceInfo.displayMetrics.widthPx.toInt()}x${androidDeviceInfo.displayMetrics.heightPx.toInt()}';
  } else {
    throw ArgumentError('Unknown device');
  }
}
