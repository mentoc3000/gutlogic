import 'package:flutter/material.dart';

import 'gl_raised_button.dart';

class GLWarningRaisedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData iconData;

  const GLWarningRaisedButton({
    Key key,
    @required this.onPressed,
    this.label,
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme;
    return GLRaisedButton(
      onPressed: onPressed,
      textColor: colorScheme.onError,
      color: colorScheme.error,
      label: label,
      iconData: iconData,
    );
  }
}
