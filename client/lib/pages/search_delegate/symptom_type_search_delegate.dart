import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/symptom_type/symptom_type.dart';
import '../../models/symptom_type.dart';
import '../../widgets/gl_loading_widget.dart';
import '../../widgets/list_tiles/gl_list_tile.dart';
import '../../widgets/gl_error_widget.dart';
import 'searchable_search_delegate.dart';
import '../../widgets/list_tiles/searchable_tile.dart';

class SymptomTypeSearchDelegate extends SearchableSearchDelegate<SymptomType> {
  final SymptomTypeBloc symptomTypeBloc;
  final String noResultsMessage = 'No results found.';

  SymptomTypeSearchDelegate({
    required this.symptomTypeBloc,
    required void Function(SymptomType) onSelect,
  }) : super(onSelect: onSelect, searchFieldLabel: 'Search for symptom') {
    symptomTypeBloc.add(FetchSymptomTypeQuery(query));
  }

  @override
  Widget buildResults(BuildContext context) {
    symptomTypeBloc.add(FetchSymptomTypeQuery(query));
    return buildList(symptomTypeBloc);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      symptomTypeBloc.add(const StreamAllSymptomTypes());
    } else {
      symptomTypeBloc.add(StreamSymptomTypeQuery(query));
    }
    return buildList(symptomTypeBloc);
  }

  Widget buildList(SymptomTypeBloc symptomTypeBloc) {
    //Build the results based on the searchResults stream in the searchBloc
    return BlocBuilder<SymptomTypeBloc, SymptomTypeState>(
      bloc: symptomTypeBloc,
      builder: (BuildContext context, SymptomTypeState state) {
        if (state is SymptomTypesLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return Column(
              children: [GLListTile(heading: noResultsMessage)],
            );
          } else {
            return ListView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final result = items[index];
                return SearchableTile(
                  searchable: result,
                  onTap: () {
                    closeSearch(context);
                    onSelect(result);
                  },
                );
              },
            );
          }
        }
        if (state is SymptomTypesLoading) {
          return GLLoadingWidget();
        }
        if (state is SymptomTypeError) {
          return GLErrorWidget(message: state.message);
        }
        return const GLErrorWidget();
      },
    );
  }
}
