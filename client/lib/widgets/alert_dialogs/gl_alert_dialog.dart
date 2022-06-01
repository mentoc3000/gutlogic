import 'package:flutter/material.dart';

class GLAlertDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;

  const GLAlertDialog({Key? key, this.title, this.content, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const actionPadding = EdgeInsets.symmetric(vertical: 6.0);
    final paddedActions = actions?.map((w) => Padding(padding: actionPadding, child: w)).toList();

    return AnimatedContainer(
      padding: mediaQuery.padding,
      duration: const Duration(milliseconds: 300),
      child: AlertDialog(
        title: title == null ? null : Text(title!),
        content: content,
        actions: paddedActions,
      ),
    );
  }
}
