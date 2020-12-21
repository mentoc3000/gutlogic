import 'package:flutter/material.dart';

import 'undo_snack_bar.dart';

class UndoDeleteSnackBar extends UndoSnackBar {
  UndoDeleteSnackBar({
    Key key,
    @required String name,
    @required void Function() onUndelete,
  }) : super(
          key: key,
          text: 'Deleted $name.',
          onUndo: onUndelete,
        );
}
