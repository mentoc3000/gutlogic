import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/model_interfaces.dart';
import '../../../widgets/alert_dialogs/confirm_delete_dialog.dart';
import '../../../widgets/dismissible/delete_dismissible.dart';
import '../../../widgets/gl_icons.dart';
import '../../../widgets/list_tiles/gl_list_tile.dart';

class SearchResultTile extends StatelessWidget {
  final Searchable searchable;
  final VoidCallback onTap;
  final FutureOr<void> Function(Searchable) onDelete;
  final bool isCustom;
  bool get isDismissible => onDelete != null;

  SearchResultTile({@required this.searchable, @required this.onTap, this.onDelete, this.isCustom = false});

  @override
  Widget build(BuildContext context) {
    final trailing = isCustom ? const Icon(GLIcons.account) : null;
    final tile = GLListTile(heading: searchable.searchHeading(), onTap: onTap, trailing: trailing);
    return isDismissible
        ? DeleteDismissible(
            child: tile,
            onDelete: () => onDelete(searchable),
            confirmDismiss: () => showDialog(
              context: context,
              builder: (_) => ConfirmDeleteDialog(itemName: searchable.searchHeading()),
            ),
          )
        : tile;
  }
}
