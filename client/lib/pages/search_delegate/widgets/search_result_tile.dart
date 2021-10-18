import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/model_interfaces.dart';
import '../../../widgets/alert_dialogs/confirm_delete_dialog.dart';
import '../../../widgets/dismissible/delete_dismissible.dart';
import '../../../widgets/gl_icons.dart';
import '../../../widgets/list_tiles/gl_list_tile.dart';

class SearchResultTile extends StatelessWidget {
  final Searchable searchable;
  final Widget? trailing;
  final VoidCallback onTap;
  final FutureOr<void> Function(Searchable)? onDelete;
  final bool isCustom;
  bool get isDismissible => onDelete != null;

  SearchResultTile({
    required this.searchable,
    this.trailing,
    required this.onTap,
    this.onDelete,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final leading = isCustom ? const Icon(GLIcons.profile) : null;
    final tile = GLListTile(heading: searchable.searchHeading(), onTap: onTap, leading: leading, trailing: trailing);

    return isDismissible
        ? DeleteDismissible(
            child: tile,
            onDelete: () => onDelete?.call(searchable),
            confirmDismiss: (_) => showDialog(
              context: context,
              builder: (_) => ConfirmDeleteDialog(itemName: searchable.searchHeading()),
            ),
          )
        : tile;
  }
}
