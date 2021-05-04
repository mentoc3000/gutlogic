import 'package:flutter/material.dart';

import '../gl_icons.dart';

class DeleteDismissible extends StatelessWidget {
  final Widget child;
  final void Function() onDelete;
  final dismissThreshold = 0.7;
  final ConfirmDismissCallback? confirmDismiss;

  const DeleteDismissible({
    Key? key,
    required this.child,
    required this.onDelete,
    this.confirmDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dismissThresholds = {for (var k in DismissDirection.values) k: dismissThreshold};

    return Dismissible(
      key: UniqueKey(),
      child: child,
      confirmDismiss: confirmDismiss,
      direction: DismissDirection.endToStart,
      dismissThresholds: dismissThresholds,
      onDismissed: (_) => onDelete(),
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
