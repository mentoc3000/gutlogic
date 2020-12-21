import 'package:flutter/material.dart';
import '../../../widgets/gl_alert_dialog.dart';

class AddFoodDialog extends StatelessWidget {
  final String initialFoodName;

  const AddFoodDialog({Key key, this.initialFoodName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    textController.text = initialFoodName ?? '';
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
      title: 'Enter new food:',
      content: content,
      actions: <Widget>[
        FlatButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
        FlatButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context, textController.text),
        ),
      ],
    );
  }
}
