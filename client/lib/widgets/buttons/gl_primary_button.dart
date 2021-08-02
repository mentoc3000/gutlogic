import 'package:flutter/material.dart';

import 'gl_raised_button.dart';

class GLPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final bool enabled;

  const GLPrimaryButton({
    Key? key,
    this.onPressed,
    this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = ButtonTheme.of(context).colorScheme!;

    return GLRaisedButton(
      onPressed: enabled ? onPressed : null,
      textColor: colorScheme.onPrimary,
      color: colorScheme.primary,
      disabledTextColor: colorScheme.onBackground,
      disabledColor: theme.disabledColor,
      child: child,
    );
  }
}
