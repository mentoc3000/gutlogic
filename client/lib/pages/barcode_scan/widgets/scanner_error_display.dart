import 'package:flutter/widgets.dart';
import 'package:gutlogic/style/gl_colors.dart';
import 'package:gutlogic/widgets/gl_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerErrorDisplay extends StatelessWidget {
  final MobileScannerErrorCode code;

  const ScannerErrorDisplay({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final String message;
    if (code == MobileScannerErrorCode.permissionDenied) {
      message = [
        'Camera permission is required to scan barcodes.',
        '',
        'Go to Settings > Gut Logic',
        'and enable Camera permission.',
      ].join('\n');
    } else {
      message = 'Unable to start the camera.';
    }

    const iconData = GLIcons.error;
    final foregroundColor = GLColors.lightestGray;

    return Center(
      child: Container(
        color: GLColors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: foregroundColor),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: foregroundColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
