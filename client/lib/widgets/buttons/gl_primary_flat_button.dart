import 'package:flutter/material.dart';

import 'gl_flat_button.dart';

class GLPrimaryFlatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData iconData;

  const GLPrimaryFlatButton({
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
      textColor: colorScheme.onPrimary,
      color: colorScheme.primary,
      disabledColor: null,
      label: label,
      iconData: iconData,
    );
  }
}
