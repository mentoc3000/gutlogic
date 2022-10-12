import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style/gl_colors.dart';
import '../util/app_config.dart';
import 'device_info_dialog.dart';

class FlavorBanner extends StatelessWidget {
  final GlobalKey navigatorKey;

  const FlavorBanner({required this.navigatorKey});

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
      final navigatorContext = navigatorKey.currentContext!;
      showDialog<void>(context: navigatorContext, builder: (context) => DeviceInfoDialog(color: color));
    }

    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: onLongPress,
        child: Container(
          width: 50,
          height: 12,
          color: color,
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 10,
                color: GLColors.white,
              ),
              child: Text(
                config.environment.name,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
