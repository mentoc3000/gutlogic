import 'package:flutter/material.dart';

import '../gl_icons.dart';
import 'gl_list_tile.dart';

class PushListTile extends StatelessWidget {
  final String heading;
  final String? subheading;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PushListTile({
    Key? key,
    required this.heading,
    this.subheading,
    this.leading,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLListTile(
      heading: heading,
      subheading: subheading,
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          const Icon(GLIcons.arrowRight),
        ],
      ),
      onTap: onTap,
    );
  }
}
