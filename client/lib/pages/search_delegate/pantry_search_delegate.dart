import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pantry/pantry.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../pages/error_page.dart';
import '../../pages/loading_page.dart';
import '../../widgets/list_tiles/gl_list_tile.dart';
import '../../widgets/list_tiles/pantry_list_tile.dart';
import '../../widgets/powered_by_edamam.dart';
import 'searchable_search_delegate.dart';

class PantrySearchDelegate extends SearchableSearchDelegate<PantryEntry> {
  final PantryBloc pantryBloc;
  final String noResultsMessage = 'No matches found. Try adding a food!';

  PantrySearchDelegate({@required this.pantryBloc, void Function(PantryEntry) onSelect})
      : super(onSelect: onSelect, searchFieldLabel: 'Search for food');

  @override
  Widget buildResults(BuildContext context) {
    pantryBloc.add(StreamPantryQuery(query));
    return buildList(pantryBloc);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }

  Widget buildList(PantryBloc pantryBloc) {
    return BlocBuilder<PantryBloc, PantryState>(
      cubit: pantryBloc,
      builder: (BuildContext context, PantryState state) {
        if (state is PantryLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return Column(
              children: [GLListTile(heading: noResultsMessage)],
            );
          } else {
            return PoweredByEdamam(
              child: ListView.builder(
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
              ),
            );
          }
        }
        if (state is PantryLoading) {
          return LoadingPage();
        }
        if (state is PantryError) {
          return ErrorPage(message: state.message);
        }
        return ErrorPage();
      },
    );
  }
}
