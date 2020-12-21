import 'package:flutter/material.dart';

import 'gl_raised_button.dart';

class GLSecondaryRaisedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData iconData;

  const GLSecondaryRaisedButton({
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
      textColor: colorScheme.onBackground,
      color: colorScheme.background,
      label: label,
      iconData: iconData,
    );
  }
}
