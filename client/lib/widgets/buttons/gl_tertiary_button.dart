import 'package:flutter/material.dart';

import 'gl_flat_button.dart';

class GLTertiaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GLTertiaryButton({
    Key key,
    @required this.onPressed,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme;
    return GLFlatButton(
      onPressed: onPressed,
      textColor: colorScheme.onBackground,
      child: child,
    );
  }
}
