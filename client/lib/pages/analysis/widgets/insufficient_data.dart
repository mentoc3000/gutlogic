import 'package:flutter/widgets.dart';
import 'package:gutlogic/widgets/buttons/buttons.dart';

import '../../../style/gl_text_style.dart';

class InsufficientData extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const InsufficientData({Key? key, required this.message, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nothing to show yet', style: tileSubheadingStyle),
            const SizedBox(height: 8.0),
            GLSecondaryButton(
              onPressed: onTap,
              child: ShrinkWrappedButtonContent(label: message),
            )
          ],
        ),
      ),
    );
  }
}
