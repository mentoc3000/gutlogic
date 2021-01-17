import 'package:flutter/material.dart';

import '../buttons/buttons.dart';
import 'gl_alert_dialog.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String itemName;

  const ConfirmDeleteDialog({Key key, @required this.itemName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLAlertDialog(
      title: 'Delete $itemName?',
      actions: <Widget>[
        GLSecondaryButton(
          child: const ShrinkWrappedButtonContent(label: 'Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        GLWarningButton(
          child: const ShrinkWrappedButtonContent(label: 'Delete'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
