import 'package:flutter/material.dart';

class GLAlertDialog extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget content;

  const GLAlertDialog({Key key, this.title, this.content, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedContainer(
      padding: mediaQuery.padding,
      duration: const Duration(milliseconds: 300),
      child: AlertDialog(
        title: title != null ? Text(title) : null,
        content: content,
        actions: actions,
      ),
    );
  }
}
