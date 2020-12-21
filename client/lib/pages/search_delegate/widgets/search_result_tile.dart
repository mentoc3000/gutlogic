import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/model_interfaces.dart';
import '../../../widgets/gl_icons.dart';
import '../../../widgets/gl_swipeable.dart';
import '../../../widgets/list_tiles/gl_list_tile.dart';

class SearchResultTile extends StatelessWidget {
  final Searchable searchable;
  final VoidCallback onTap;
  final FutureOr<void> Function(Searchable) onDelete;
  final bool isCustom;
  bool get isSwipeable => onDelete != null;

  SearchResultTile({@required this.searchable, @required this.onTap, this.onDelete, this.isCustom = false});

  @override
  Widget build(BuildContext context) {
    final trailing = isCustom ? const Icon(GLIcons.account) : null;
    final tile = GLListTile(heading: searchable.searchHeading(), onTap: onTap, trailing: trailing);
    return isSwipeable ? GLSwipeable(child: tile, onDelete: () => onDelete(searchable)) : tile;
  }
}
