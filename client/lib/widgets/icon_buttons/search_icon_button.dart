import 'package:flutter/material.dart';
import '../gl_icons.dart';

class SearchIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SearchIconButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(GLIcons.search),
      tooltip: 'Search',
      onPressed: onPressed,
    );
  }
}
