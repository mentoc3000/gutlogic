import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';

import 'screenshots_util.dart';

/// A DataHandler for enableFlutterDriverExtension so the screenshots driver can request data while driving.
Future<String> handler(String? message) async {
  if (message == requestPlatformMessage) {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    throw ArgumentError('Unknown platform.');
  }

  if (message == requestDeviceNameMessage) {
    if (Platform.isAndroid) return (await DeviceInfoPlugin().androidInfo).device;
    if (Platform.isIOS) return (await DeviceInfoPlugin().iosInfo).name;
    throw ArgumentError('Unknown platform.');
  }

  if (message == requestLocaleNameMessage) {
    return 'en-US'; // TODO find a way to return the device locale without a BuildContext
  }

  throw ArgumentError('Unrecognized driver message $message');
}
