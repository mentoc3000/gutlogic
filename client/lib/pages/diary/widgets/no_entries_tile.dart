import 'package:flutter/material.dart';
import '../../../style/gl_colors.dart';
import '../../../style/gl_theme.dart';

class NoEntriesTile extends StatelessWidget {
  final bool showElipses;
  const NoEntriesTile({this.showElipses = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GLColors.transparent,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          if (showElipses) const Icon(Icons.more_vert),
          const Text(
            'No Entries',
            style: tileHeadingTheme,
          ),
          if (showElipses) const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
