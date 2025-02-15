import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/pantry/pantry.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import '../../widgets/list_tiles/pantry_list_tile.dart';
import 'searchable_search_delegate.dart';

class PantrySearchDelegate extends SearchableSearchDelegate<PantryEntry> {
  final PantryBloc pantryBloc;

  PantrySearchDelegate({
    required this.pantryBloc,
    required void Function(PantryEntry) onSelect,
  }) : super(
          onSelect: onSelect,
          searchFieldLabel: 'Search for food',
        ) {
    pantryBloc.add(StreamPantryQuery(query));
  }

  @override
  Widget buildResults(BuildContext context) {
    pantryBloc.add(StreamPantryQuery(query));
    return buildList(pantryBloc);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Column();
  }

  Widget buildList(PantryBloc pantryBloc) {
    return BlocBuilder<PantryBloc, PantryState>(
      bloc: pantryBloc,
      builder: (BuildContext context, PantryState state) {
        if (state is PantryLoaded) {
          final items = state.items;
          return ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final result = items[index];
              return PantryListTile(
                pantryEntry: result,
                onTap: () {
                  closeSearch(context);
                  onSelect(result);
                },
              );
            },
          );
        }
        if (state is PantryLoading) {
          return GLLoadingWidget();
        }
        if (state is PantryError) {
          return GLErrorWidget(message: state.message);
        }
        return const GLErrorWidget();
      },
    );
  }
}
