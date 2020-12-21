import 'package:flutter/material.dart';

import 'gl_raised_button.dart';

class GLPrimaryRaisedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData iconData;

  const GLPrimaryRaisedButton({
    Key key,
    @required this.onPressed,
    this.label,
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = ButtonTheme.of(context).colorScheme;
    return GLRaisedButton(
      onPressed: onPressed,
      textColor: colorScheme.onPrimary,
      color: colorScheme.primary,
      disabledTextColor: colorScheme.onBackground,
      disabledColor: theme.disabledColor,
      label: label,
      iconData: iconData,
    );
  }
}
