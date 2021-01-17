import 'package:flutter/material.dart';

import 'gl_raised_button.dart';

class GLPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GLPrimaryButton({
    Key key,
    @required this.onPressed,
    @required this.child,
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
      child: child,
    );
  }
}
