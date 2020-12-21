import 'package:device_info/device_info.dart';

DeviceInfoPlugin _plugin;

Future<AndroidDeviceInfo> get androidDeviceInfo {
  _plugin ??= DeviceInfoPlugin();
  return _plugin.androidInfo;
}

Future<IosDeviceInfo> get iosDeviceInfo {
  _plugin ??= DeviceInfoPlugin();
  return _plugin.iosInfo;
}
