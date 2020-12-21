import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'gl_icons.dart';

class GLSwipeable extends StatelessWidget {
  final Widget child;
  final void Function() onDelete;

  const GLSwipeable({Key key, @required this.child, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      child: child,
      confirmDismiss: (DismissDirection direction) async => direction == DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          GLIcons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
    );
  }
}
