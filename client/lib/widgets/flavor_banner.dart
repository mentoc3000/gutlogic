import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style/gl_colors.dart';
import '../util/app_config.dart';
import 'device_info_dialog.dart';

class FlavorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = context.read<AppConfig>();

    final Color color;

    switch (config.environment) {
      case Environment.development:
        color = GLColors.development;
        break;
      case Environment.production:
        color = GLColors.production;
        break;
    }

    void onLongPress() {
      showDialog(context: context, builder: (context) => DeviceInfoDialog(color: color));
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: onLongPress,
      child: Container(
        width: 50,
        height: 50,
        child: CustomPaint(
          painter: BannerPainter(
            message: config.environment.name,
            textDirection: Directionality.of(context),
            layoutDirection: Directionality.of(context),
            location: BannerLocation.topStart,
            color: color,
          ),
        ),
      ),
    );
  }
}
