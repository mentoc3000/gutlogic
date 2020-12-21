import 'package:flutter/material.dart';

import 'gl_button.dart';

class GLFlatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ButtonTextTheme textTheme;
  final Color textColor;
  final Color disabledTextColor;
  final Color color;
  final Color disabledColor;
  final double elevation = 0.0;
  final double focusElevation = 0.0;
  final double hoverElevation = 0.0;
  final double highlightElevation = 0.0;
  final double disabledElevation = 0.0;
  final TextStyle textStyle;
  final String label;
  final IconData iconData;
  final Widget leader;
  final Widget disabledLeader;

  GLFlatButton({
    Key key,
    @required this.onPressed,
    this.textTheme,
    this.textColor,
    this.disabledTextColor,
    this.color,
    this.disabledColor,
    this.textStyle,
    this.label,
    this.iconData,
    this.leader,
    this.disabledLeader,
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
      label: label,
      leader: leader,
      disabledLeader: disabledLeader,
    );
  }
}
