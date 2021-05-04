import 'package:device_info/device_info.dart';

DeviceInfoPlugin _plugin = DeviceInfoPlugin();

Future<AndroidDeviceInfo> get androidDeviceInfo {
  return _plugin.androidInfo;
}

Future<IosDeviceInfo> get iosDeviceInfo {
  return _plugin.iosInfo;
}
