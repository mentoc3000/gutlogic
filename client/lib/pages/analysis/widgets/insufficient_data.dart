import 'package:flutter/widgets.dart';

import '../../../style/gl_text_style.dart';

class InsufficientData extends StatelessWidget {
  final String message;

  const InsufficientData({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Text(
          message,
          style: tileSubheadingStyle.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
