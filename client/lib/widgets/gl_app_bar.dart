import 'package:flutter/material.dart';

class GLAppBar extends AppBar {
  GLAppBar({
    Key key,
    String title,
    Widget leading,
    List<Widget> actions,
  }) : super(
          key: key,
          centerTitle: true,
          title: title == null ? null : Text(title),
          leading: leading,
          actions: actions,
        );
}
