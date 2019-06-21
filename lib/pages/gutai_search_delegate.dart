import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';
import '../blocs/searchable_bloc.dart';
import '../blocs/searchable_event.dart';
import '../blocs/searchable_state.dart';

class GutAiSearchDelegate<T extends Searchable> extends SearchDelegate {
  SearchableBloc searchableBloc;
  final void Function(T) onSelect;

  GutAiSearchDelegate({this.searchableBloc, this.onSelect});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  closeSearch(BuildContext context) {
    close(context, null);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => closeSearch(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(query);
    searchableBloc.dispatch(FetchQuery(query));

    return Column(
      children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        BlocBuilder(
          bloc: searchableBloc,
          builder: (BuildContext context, SearchableState state) {
            if (state is SearchableLoaded<T>) {
              BuiltList<T> items = state.items;
              if (items.length == 0) {
                return Column(
                  children: <Widget>[
                    Text(
                      "No Results Found.",
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var result = items[index];
                    return ListTile(
                        title: Text(result.searchHeading()),
                        onTap: () {
                          this.onSelect(result);
                          closeSearch(context);
                        });
                  },
                );
              }
            }
            if (state is SearchableLoading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (state is SearchableError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: Text('An error has occurred.')),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }
}
