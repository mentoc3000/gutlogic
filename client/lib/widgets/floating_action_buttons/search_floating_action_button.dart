import 'package:flutter/material.dart';

import '../gl_icons.dart';

class SearchFloatingActionButton extends StatelessWidget {
  final void Function() onPressed;

  const SearchFloatingActionButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(GLIcons.search),
      onPressed: onPressed,
    );
  }
}
