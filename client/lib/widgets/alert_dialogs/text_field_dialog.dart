import 'package:flutter/material.dart';

import '../buttons/buttons.dart';
import 'gl_alert_dialog.dart';

class TextFieldDialog extends StatelessWidget {
  final String initialText;
  final String title;

  const TextFieldDialog({Key? key, required this.title, this.initialText = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    textController.text = initialText;
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
        GLSecondaryButton(
          child: const ShrinkWrappedButtonContent(label: 'Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        GLPrimaryButton(
          child: const ShrinkWrappedButtonContent(label: 'OK'),
          onPressed: () => Navigator.pop(context, textController.text),
        ),
      ],
    );
  }
}
