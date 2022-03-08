import 'package:flutter/material.dart';

import 'button_helpers.dart';

class GLButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress = null;
  final ValueChanged<bool>? onHighlightChanged = null;
  final ButtonTextTheme? textTheme;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? color;
  final Color? disabledColor;
  final Color? focusColor = null;
  final Color? hoverColor = null;
  final Color? highlightColor = null;
  final Color? splashColor = null;
  final Brightness? colorBrightness = null;
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final EdgeInsetsGeometry padding = EdgeInsets.zero;
  final VisualDensity? visualDensity = null;
  final Clip clipBehavior = Clip.none;
  final FocusNode? focusNode = null;
  final bool autoFocus = false;
  final MaterialTapTargetSize? materialTapTargetSize = null;
  final Duration? animationDuration = null;
  final TextStyle? textStyle;
  final Widget? child;

  bool get isDisabled => onPressed == null;

  GLButton({
    Key? key,
    required this.onPressed,
    this.textTheme,
    this.textColor,
    this.disabledTextColor,
    this.color,
    this.disabledColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.textStyle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = buttonHeight(context);
    final ShapeBorder shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(height * 0.5)); // maximize radius

    return SizedBox.fromSize(
      size: Size(double.infinity, height),
      child: MaterialButton(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHighlightChanged: onHighlightChanged,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        disabledColor: disabledColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        colorBrightness: colorBrightness,
        elevation: elevation,
        focusElevation: focusElevation,
        hoverElevation: hoverElevation,
        highlightElevation: highlightElevation,
        disabledElevation: disabledElevation,
        padding: padding,
        visualDensity: visualDensity,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autoFocus,
        materialTapTargetSize: materialTapTargetSize,
        animationDuration: animationDuration,
        child: child,
        minWidth: height,
        height: height,
      ),
    );
  }
}
