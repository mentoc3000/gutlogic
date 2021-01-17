import 'package:flutter/material.dart';
import '../../models/sensitivity.dart';

class GLListTile extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget leading;
  final void Function() onTap;
  final bool dense;
  final Widget trailing;

  const GLListTile(
      {this.heading, this.subheading, this.sensitivity, this.leading, this.trailing, this.onTap, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final headingWidget = Text(heading);
    final subheadingWidget = (subheading != null && subheading != '') ? Text(subheading) : null;

    return ListTile(
      title: headingWidget,
      subtitle: subheadingWidget,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      dense: dense,
    );
  }
}
