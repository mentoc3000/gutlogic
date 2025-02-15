import 'package:flutter/material.dart';

import '../../style/gl_text_style.dart';

class HeaderListTile extends StatelessWidget {
  final String heading;
  final VoidCallback? onTap;
  final Widget? trailing;

  const HeaderListTile({required this.heading, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(heading, style: tileHeadingStyle),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
