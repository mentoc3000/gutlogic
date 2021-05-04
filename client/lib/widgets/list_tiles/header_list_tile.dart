import 'package:flutter/material.dart';

import '../../style/gl_theme.dart';

class HeaderListTile extends StatelessWidget {
  final String heading;

  const HeaderListTile({required this.heading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(heading, style: tileHeadingTheme),
    );
  }
}
