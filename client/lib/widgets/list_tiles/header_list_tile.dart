import 'package:flutter/material.dart';
import '../../style/gl_theme.dart';

class HeaderListTile extends StatelessWidget {
  final String heading;

  const HeaderListTile({this.heading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(heading, style: tileHeadingTheme),
    );
  }
}
