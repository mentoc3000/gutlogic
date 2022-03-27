import 'package:flutter/material.dart';

import 'gl_button.dart';

class GLRaisedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ButtonTextTheme? textTheme;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? color;
  final Color? disabledColor;
  final double? elevation = null;
  final double? focusElevation = null;
  final double? hoverElevation = null;
  final double? highlightElevation = null;
  final double? disabledElevation = null;
  final TextStyle? textStyle;
  final Widget? child;

  const GLRaisedButton({
    Key? key,
    this.onPressed,
    this.textTheme,
    this.textColor,
    this.disabledTextColor,
    this.color,
    this.disabledColor,
    this.textStyle,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLButton(
      onPressed: onPressed,
      textTheme: textTheme,
      textColor: textColor,
      color: color,
      disabledTextColor: disabledTextColor,
      disabledColor: disabledColor,
      elevation: elevation,
      focusElevation: focusElevation,
      hoverElevation: hoverElevation,
      highlightElevation: highlightElevation,
      disabledElevation: disabledElevation,
      textStyle: textStyle,
      child: child,
    );
  }
}
