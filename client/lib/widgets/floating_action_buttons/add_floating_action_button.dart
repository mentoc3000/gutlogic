import 'package:flutter/material.dart';

import '../gl_icons.dart';

class AddFloatingActionButton extends StatelessWidget {
  final void Function()? onPressed;

  const AddFloatingActionButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(GLIcons.add),
    );
  }
}
