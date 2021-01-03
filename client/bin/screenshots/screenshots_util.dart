import 'package:logger/logger.dart';

final log = Logger(
  filter: ProductionFilter(),
  printer: SimplePrinter(printTime: true),
);

const String requestPlatformMessage = 'request_platform';
const String requestDeviceNameMessage = 'request_device_name';
const String requestLocaleNameMessage = 'request_locale_name';
