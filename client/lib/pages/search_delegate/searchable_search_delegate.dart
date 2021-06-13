import 'package:flutter/material.dart';

import '../../models/model_interfaces.dart';
import '../../style/gl_color_scheme.dart';
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
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headline6: theme.textTheme.headline6?.copyWith(color: theme.colorScheme.onPrimary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: glColorScheme.onPrimary,
        selectionColor: glColorScheme.onPrimary.withOpacity(0.5),
        selectionHandleColor: glColorScheme.onPrimary,
      ),
    );
  }
}
