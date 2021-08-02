import 'package:flutter/material.dart';

import 'gl_flat_button.dart';

class GLTertiaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final bool enabled;

  const GLTertiaryButton({
    Key? key,
    this.onPressed,
    this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme!;

    return GLFlatButton(
      onPressed: enabled ? onPressed : null,
      textColor: colorScheme.onBackground,
      child: child,
    );
  }
}
