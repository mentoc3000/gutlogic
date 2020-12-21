import 'package:flutter/material.dart';

import 'gl_flat_button.dart';

class GLWarningFlatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData iconData;

  const GLWarningFlatButton({
    Key key,
    @required this.onPressed,
    this.label,
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme;
    return GLFlatButton(
      onPressed: onPressed,
      textColor: colorScheme.onError,
      color: colorScheme.error,
      label: label,
      iconData: iconData,
    );
  }
}
