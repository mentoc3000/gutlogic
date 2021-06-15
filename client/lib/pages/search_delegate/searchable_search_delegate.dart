import 'package:flutter/material.dart';

import '../../models/model_interfaces.dart';
import '../../style/gl_theme.dart';
import '../../widgets/gl_icons.dart';
import '../../widgets/list_tiles/gl_list_tile.dart';

abstract class SearchableSearchDelegate<T extends Searchable> extends SearchDelegate<T?> {
  final void Function(T) onSelect;

  SearchableSearchDelegate({
    required String searchFieldLabel,
    required this.onSelect,
  }) : super(searchFieldLabel: searchFieldLabel);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(GLIcons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  void closeSearch(BuildContext context) => close(context, null);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(GLIcons.arrowBack),
      onPressed: () => closeSearch(context),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => Container();

  Widget buildListTile({
    required BuildContext context,
    required T searchable,
    Widget? trailing,
  }) =>
      GLListTile(
        heading: searchable.searchHeading(),
        onTap: () {
          closeSearch(context);
          onSelect(searchable);
        },
        trailing: trailing,
      );

  @override
  ThemeData appBarTheme(BuildContext context) => searchDelegateTheme;
}
