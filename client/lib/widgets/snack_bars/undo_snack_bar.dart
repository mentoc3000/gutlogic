import 'package:flutter/material.dart';

import 'gl_snack_bar.dart';

class UndoSnackBar extends GLSnackBar {
  UndoSnackBar({
    Key key,
    @required String text,
    @required VoidCallback onUndo,
  }) : super(
          key: key,
          text: text,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: onUndo,
          ),
        );
}
