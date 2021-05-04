import 'package:flutter/widgets.dart';

double buttonHeight(BuildContext context) {
  const heightToFontSizeRatio = 7 / 3; // Conforms to Apple's log in button requirements

  final textScaleFactor = MediaQuery.of(context).textScaleFactor;
  final fontSize = DefaultTextStyle.of(context).style.fontSize ?? 14;

  return heightToFontSizeRatio * fontSize * textScaleFactor;
}
