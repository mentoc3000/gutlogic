import 'package:flutter/material.dart';

import '../gl_icons.dart';

class FilterIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const FilterIconButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(GLIcons.filter),
      tooltip: 'Filter',
      onPressed: onPressed,
    );
  }
}
