import 'package:flutter/material.dart';

class GLListTile extends StatelessWidget {
  final String heading;
  final String? subheading;
  final Widget? leading;
  final void Function()? onTap;
  final bool dense;
  final Widget? trailing;

  const GLListTile({
    required this.heading,
    this.subheading,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(heading);
    final subtitle = subheading?.isNotEmpty == true ? Text(subheading!) : null;

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
