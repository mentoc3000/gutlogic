import 'package:flutter/material.dart';

import 'gl_popup_menu_item.dart';

class GLPopupMenuButton<T> extends StatelessWidget {
  final PopupMenuItemSelected<T> onSelected;
  final List<GLPopupMenuItem<T>> items;
  final Icon? icon;
  final Widget? child;

  const GLPopupMenuButton({Key? key, this.icon, this.child, required this.onSelected, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => items,
      icon: icon,
      child: child,
    );
  }
}
