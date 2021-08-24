import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

import 'screenshots_util.dart';

/// A DataHandler for enableFlutterDriverExtension so the screenshots driver can request data while driving.
Future<String> handler(String? message) async {
  if (message == requestPlatformMessage) {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    throw ArgumentError('Unknown platform.');
  }

  if (message == requestDeviceNameMessage) {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await plugin.androidInfo).device ?? '';
    if (Platform.isIOS) return (await plugin.iosInfo).name ?? '';
    throw ArgumentError('Unknown platform.');
  }

  if (message == requestLocaleNameMessage) {
    return 'en-US'; // TODO find a way to return the device locale without a BuildContext
  }

  throw ArgumentError('Unrecognized driver message $message');
}
