import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/food/food.dart';
import '../../models/food/custom_food.dart';
import '../../models/food/food.dart';
import '../../pages/error_page.dart';
import '../../pages/loading_page.dart';
import '../../widgets/list_tiles/gl_list_tile.dart';
import '../../widgets/powered_by_edamam.dart';
import 'searchable_search_delegate.dart';
import 'widgets/search_result_tile.dart';

class FoodSearchDelegate extends SearchableSearchDelegate<Food> {
  final FoodBloc foodBloc;
  final String noResultsMessage = 'No matches found. Try adding a food!';

  FoodSearchDelegate({
    this.foodBloc,
    @required void Function(Food) onSelect,
    FutureOr<String> Function(String) onAdd,
    FutureOr<void> Function(Food) onDelete,
  }) : super(
          onSelect: onSelect,
          onAdd: onAdd,
          onDelete: (food) => onDelete(food),
          searchFieldLabel: 'Search for food',
        );

  @override
  Widget buildResults(BuildContext context) {
    foodBloc.add(StreamFoodQuery(query));
    return buildList(foodBloc);
  }

  @override
  // Widget buildSuggestions(BuildContext context) => buildResults(context);
  Widget buildSuggestions(BuildContext context) {
    foodBloc.add(StreamFoodQuery(query));
    return buildList(foodBloc);
  }

  Widget buildList(FoodBloc foodBloc) {
    return BlocBuilder<FoodBloc, FoodState>(
      bloc: foodBloc,
      builder: (BuildContext context, FoodState state) {
        if (state is FoodsLoaded) {
          final items = state.items;
          if (query.isEmpty) {
            return Column(children: []);
          } else {
            return addFab(
              PoweredByEdamam(
                child: ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final result = items[index];
                    return SearchResultTile(
                      searchable: result,
                      onTap: () {
                        closeSearch(context);
                        onSelect(result);
                      },
                      onDelete: onDelete,
                      isCustom: result is CustomFood,
                    );
                  },
                ),
              ),
            );
          }
        }
        if (state is NoFoodsFound) {
          return addFab(Column(
            children: [GLListTile(heading: noResultsMessage)],
          ));
        }
        if (state is FoodsLoading) {
          return addFab(LoadingPage());
        }
        if (state is FoodError) {
          return ErrorPage(message: state.message);
        }
        return ErrorPage();
      },
    );
  }
}
