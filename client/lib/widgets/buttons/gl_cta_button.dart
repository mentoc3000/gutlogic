import 'package:flutter/material.dart';

import '../../style/gl_colors.dart';
import 'gl_raised_button.dart';

/// Call to action button
class GLCtaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;

  const GLCtaButton({
    Key? key,
    this.onPressed,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = ButtonTheme.of(context).colorScheme!;

    return GLRaisedButton(
      onPressed: onPressed,
      textColor: GLColors.darkestGray,
      color: GLColors.cta,
      disabledTextColor: colorScheme.onBackground,
      disabledColor: theme.disabledColor,
      child: child,
    );
  }
}
