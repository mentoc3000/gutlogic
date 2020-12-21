import 'package:flutter/material.dart';

export 'gl_flat_button.dart';
export 'gl_primary_flat_button.dart';
export 'gl_primary_raised_button.dart';
export 'gl_raised_button.dart';
export 'gl_secondary_flat_button.dart';
export 'gl_secondary_raised_button.dart';
export 'gl_warning_flat_button.dart';
export 'gl_warning_raised_button.dart';

class GLButton extends StatelessWidget {
  static const height = 38.0;
  static const fontSize = 16.0; // Adheres to Apple's font/height = .43 requirement
  static const defaultIconSize = 18.0;
  static const borderRadius = GLButton.height / 2;

  final VoidCallback onPressed;
  final VoidCallback onLongPress = null;
  final ValueChanged<bool> onHighlightChanged = null;
  final ButtonTextTheme textTheme;
  final Color textColor;
  final Color disabledTextColor;
  final Color color;
  final Color disabledColor;
  final Color focusColor = null;
  final Color hoverColor = null;
  final Color highlightColor = null;
  final Color splashColor = null;
  final Brightness colorBrightness = null;
  final double elevation;
  final double focusElevation;
  final double hoverElevation;
  final double highlightElevation;
  final double disabledElevation;
  final EdgeInsetsGeometry padding = EdgeInsets.zero;
  final VisualDensity visualDensity = null;
  final ShapeBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(GLButton.borderRadius));
  final Clip clipBehavior = Clip.none;
  final FocusNode focusNode = null;
  final bool autoFocus = false;
  final MaterialTapTargetSize materialTapTargetSize = null;
  final Duration animationDuration = null;
  final TextStyle textStyle;
  final String label;
  final Widget leader;
  final Widget disabledLeader;

  bool get isDisabled => onPressed == null;

  GLButton({
    Key key,
    @required this.onPressed,
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
    this.label,
    this.leader,
    this.disabledLeader,
  }) : super(key: key);

  static Widget iconLeader({IconData iconData, Color color, double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: color, size: size),
        const SizedBox(width: 8.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontSize: fontSize).merge(this.textStyle);

    final text = Padding(
      padding: const EdgeInsets.only(left: GLButton.borderRadius, right: GLButton.borderRadius),
      child: Text(label, textAlign: TextAlign.center, style: textStyle),
    );

    Widget child;

    if (leader == null) {
      child = text;
    } else {
      final showDisabledLeader = isDisabled && disabledLeader != null;

      // Stack the leader on top of the label text, and expand the label to the maximum width of the button, so the
      // label is centered to the button width and not offset by the leader width.

      child = Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          showDisabledLeader ? disabledLeader : leader,
          SizedBox(width: double.infinity, child: text),
        ],
      );
    }

    return ButtonTheme(
      minWidth: 140,
      height: height,
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
      ),
    );
  }
}
