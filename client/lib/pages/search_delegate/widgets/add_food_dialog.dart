import 'package:flutter/material.dart';

import '../../../style/gl_theme.dart';
import '../../../widgets/alert_dialogs/text_field_dialog.dart';

class AddFoodDialog extends StatelessWidget {
  final String initialFoodName;

  const AddFoodDialog({Key? key, required this.initialFoodName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap in Theme to correct headline color
    return Theme(
      data: glTheme,
      child: TextFieldDialog(
        title: 'Enter new food:',
        initialText: initialFoodName,
      ),
    );
  }
}
