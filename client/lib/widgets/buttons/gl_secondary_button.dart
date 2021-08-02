import 'package:flutter/material.dart';

import '../../style/gl_colors.dart';
import 'gl_raised_button.dart';

class GLSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final bool enabled;

  const GLSecondaryButton({
    Key? key,
    this.onPressed,
    this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme!;

    return GLRaisedButton(
      onPressed: enabled ? onPressed : null,
      textColor: colorScheme.onBackground,
      color: GLColors.lighterGray,
      child: child,
    );
  }
}
