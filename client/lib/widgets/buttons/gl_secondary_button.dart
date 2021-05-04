import 'package:flutter/material.dart';

import '../../style/gl_colors.dart';
import 'gl_raised_button.dart';

class GLSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;

  const GLSecondaryButton({
    Key? key,
    this.onPressed,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme!;
    return GLRaisedButton(
      onPressed: onPressed,
      textColor: colorScheme.onBackground,
      color: GLColors.lighterGray,
      child: child,
    );
  }
}
