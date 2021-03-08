import 'package:flutter/material.dart';
import '../gl_icons.dart';

class SortIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SortIconButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(GLIcons.sort),
      tooltip: 'Sort',
      onPressed: onPressed,
    );
  }
}
