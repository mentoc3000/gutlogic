import 'package:flutter/material.dart';

import '../util/app_config.dart';
import 'device_info_dialog.dart';

class FlavorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = AppConfig.of(context);

    if (config == null) return Container();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () => showDeviceInfoDialog(context),
      child: Container(
        width: 50,
        height: 50,
        child: CustomPaint(
          painter: BannerPainter(
            message: config.name,
            textDirection: Directionality.of(context),
            layoutDirection: Directionality.of(context),
            location: BannerLocation.topStart,
            color: getAppEnvironmentColor(config.environment),
          ),
        ),
      ),
    );
  }

  static void showDeviceInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeviceInfoDialog(),
    );
  }
}
