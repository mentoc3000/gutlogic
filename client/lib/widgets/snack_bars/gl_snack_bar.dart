import 'package:flutter/material.dart';

abstract class GLSnackBar extends SnackBar {
  GLSnackBar({
    Key key,
    @required String text,
    Color textColor,
    Color backgroundColor,
    SnackBarAction action,
  }) : super(
          key: key,
          content: Text(text, style: TextStyle(color: textColor)),
          backgroundColor: backgroundColor,
          action: action,
        );
}
