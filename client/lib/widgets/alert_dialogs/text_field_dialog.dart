import 'package:flutter/material.dart';
import '../buttons/gl_primary_flat_button.dart';
import '../buttons/gl_secondary_flat_button.dart';
import 'gl_alert_dialog.dart';

class TextFieldDialog extends StatelessWidget {
  final String initialText;
  final String title;

  const TextFieldDialog({Key key, @required this.title, this.initialText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    textController.text = initialText ?? '';
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: textController,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
      ],
    );

    return GLAlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        GLSecondaryFlatButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        GLPrimaryFlatButton(label: 'OK', onPressed: () => Navigator.pop(context, textController.text)),
      ],
    );
  }
}
