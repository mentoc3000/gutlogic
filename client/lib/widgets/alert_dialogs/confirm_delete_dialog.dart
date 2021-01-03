import 'package:flutter/material.dart';
import '../buttons/gl_secondary_flat_button.dart';
import '../buttons/gl_warning_flat_button.dart';
import 'gl_alert_dialog.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String itemName;

  const ConfirmDeleteDialog({Key key, @required this.itemName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLAlertDialog(
      title: 'Delete $itemName?',
      actions: <Widget>[
        GLSecondaryFlatButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        GLWarningFlatButton(label: 'Delete', onPressed: () => Navigator.pop(context, true)),
      ],
    );
  }
}
