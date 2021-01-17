import 'package:flutter/material.dart';

import '../../../widgets/buttons/gl_flat_button.dart';

class DeleteAccountButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const DeleteAccountButton({
    Key key,
    @required this.onPressed,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ButtonTheme.of(context).colorScheme;
    return GLFlatButton(
      onPressed: onPressed,
      textColor: colorScheme.error,
      child: child,
    );
  }
}
