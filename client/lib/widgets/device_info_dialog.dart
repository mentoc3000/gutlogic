import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import '../style/gl_colors.dart';
import '../util/app_config.dart';
import '../util/device_utils.dart';

Color getAppEnvironmentColor(Environment env) {
  switch (env) {
    case Environment.development:
      return GLColors.development;
    case Environment.production:
      return GLColors.production;
  }
  throw 'Unknown environment $env';
}

class DeviceInfoDialog extends StatelessWidget {
  DeviceInfoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(bottom: 10.0),
      title: Container(
        padding: const EdgeInsets.all(15.0),
        color: getAppEnvironmentColor(AppConfig.of(context).environment),
        child: const Text(
          'Device Info',
          style: TextStyle(color: GLColors.white),
        ),
      ),
      titlePadding: const EdgeInsets.all(0),
      content: _getContent(context),
    );
  }

  Widget _getContent(BuildContext context) {
    if (Platform.isAndroid) {
      return _androidContent(context);
    }
    if (Platform.isIOS) {
      return _iOSContent(context);
    }
    return const Text("You're not on Android neither iOS");
  }

  Widget _androidContent(BuildContext context) {
    final appconfig = AppConfig.of(context);

    return FutureBuilder(
        future: androidDeviceInfo,
        builder: (context, AsyncSnapshot<AndroidDeviceInfo> snapshot) {
          if (!snapshot.hasData) return Container();
          final device = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildTile('Flavor:', appconfig.name),
                _buildTile('Build mode:', appconfig.buildmode),
                _buildTile('Physical device:', device.isPhysicalDevice),
                _buildTile('Manufacturer:', device.manufacturer),
                _buildTile('Model:', device.model),
                _buildTile('Android version:', device.version.release),
                _buildTile('Android SDK:', device.version.sdkInt)
              ],
            ),
          );
        });
  }

  Widget _iOSContent(BuildContext context) {
    final appconfig = AppConfig.of(context);

    return FutureBuilder(
        future: iosDeviceInfo,
        builder: (context, AsyncSnapshot<IosDeviceInfo> snapshot) {
          if (!snapshot.hasData) return Container();

          final device = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildTile('Flavor:', appconfig.name),
                _buildTile('Build mode:', appconfig.buildmode),
                _buildTile('Physical device:', device.isPhysicalDevice),
                _buildTile('Device:', device.name),
                _buildTile('Model:', device.model),
                _buildTile('System name:', device.systemName),
                _buildTile('System version:', device.systemVersion)
              ],
            ),
          );
        });
  }

  Widget _buildTile(String key, Object value) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value.toString())
        ],
      ),
    );
  }
}
