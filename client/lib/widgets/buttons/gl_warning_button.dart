import 'package:flutter/material.dart';

import 'gl_raised_button.dart';

class GLWarningButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;

  const GLWarningButton({
    Key? key,
    this.onPressed,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme!;
    return GLRaisedButton(
      onPressed: onPressed,
      textColor: colorScheme.onError,
      color: colorScheme.error,
      child: child,
    );
  }
}
