import 'package:flutter/material.dart';

class GLListTile extends StatelessWidget {
  final String heading;
  final Widget? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool dense;
  final Widget? trailing;

  const GLListTile({
    required this.heading,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(heading);

    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      dense: dense,
    );
  }
}
