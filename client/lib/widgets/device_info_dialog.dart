import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/user_repository.dart';
import '../style/gl_colors.dart';
import '../util/app_config.dart';

class DeviceInfoDialog extends StatelessWidget {
  final Color color;

  const DeviceInfoDialog({required this.color});

  @override
  Widget build(BuildContext context) {
    final plugin = DeviceInfoPlugin();
    final config = context.read<AppConfig>();

    Widget? content;

    if (Platform.isAndroid) {
      content = FutureBuilder(
        future: plugin.androidInfo,
        builder: (context, snapshot) => snapshot.hasData
            ? AndroidDeviceInfoContent(config: config, device: snapshot.data as AndroidDeviceInfo)
            : Container(),
      );
    } else if (Platform.isIOS) {
      content = FutureBuilder(
        future: plugin.iosInfo,
        builder: (context, snapshot) => snapshot.hasData
            ? IosDeviceInfoContent(config: config, device: snapshot.data as IosDeviceInfo)
            : Container(),
      );
    }

    return AlertDialog(
      contentPadding: const EdgeInsets.only(bottom: 10.0),
      title: Container(
        padding: const EdgeInsets.all(15.0),
        color: color,
        child: const Text('Device Info', style: TextStyle(color: GLColors.white)),
      ),
      titlePadding: const EdgeInsets.all(0),
      content: content,
    );
  }
}

String getUserIdString(String? userId) {
  late final String splitId;
  if (userId != null) {
    final splitIdx = (userId.length / 2).floor();
    splitId = '${userId.substring(0, splitIdx)}\n${userId.substring(splitIdx)}';
  } else {
    splitId = 'null';
  }
  return splitId;
}

class IosDeviceInfoContent extends StatelessWidget {
  final AppConfig config;
  final IosDeviceInfo device;

  const IosDeviceInfoContent({required this.config, required this.device});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserRepository>().user?.id;
    final splitId = getUserIdString(userId);
    final server = config.isProduction ? 'prod' : 'dev';

    return SingleChildScrollView(
      child: Column(
        children: [
          DeviceInfoElement('Environment:', config.environment.name),
          DeviceInfoElement('Build:', config.build),
          DeviceInfoElement('Physical Device:', device.isPhysicalDevice),
          DeviceInfoElement('Device:', device.name),
          DeviceInfoElement('Model:', device.model),
          DeviceInfoElement('System Name:', device.systemName),
          DeviceInfoElement('System Version:', device.systemVersion),
          DeviceInfoElement('User ID:', splitId),
          DeviceInfoElement('Server', server),
        ],
      ),
    );
  }
}

class AndroidDeviceInfoContent extends StatelessWidget {
  final AppConfig config;
  final AndroidDeviceInfo device;

  const AndroidDeviceInfoContent({required this.config, required this.device});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserRepository>().user?.id;
    final splitId = getUserIdString(userId);
    final server = config.isProduction ? 'prod' : 'dev';

    return SingleChildScrollView(
      child: Column(
        children: [
          DeviceInfoElement('Environment:', config.environment.name),
          DeviceInfoElement('Build:', config.build),
          DeviceInfoElement('Physical Device:', device.isPhysicalDevice),
          DeviceInfoElement('Manufacturer:', device.manufacturer),
          DeviceInfoElement('Model:', device.model),
          DeviceInfoElement('Android Version:', device.version.release),
          DeviceInfoElement('Android SDK:', device.version.sdkInt),
          DeviceInfoElement('User ID:', splitId),
          DeviceInfoElement('Server', server),
        ],
      ),
    );
  }
}

class DeviceInfoElement extends StatelessWidget {
  final String title;
  final String value;

  DeviceInfoElement(this.title, Object? value) : value = value?.toString() ?? 'null';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, maxLines: 2),
        ],
      ),
    );
  }
}
