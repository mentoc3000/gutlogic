import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_search/food_search.dart';
import '../../models/food/food.dart';
import '../../pages/error_page.dart';
import '../../pages/loading_page.dart';
import '../../widgets/fab_guide.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_scaffold.dart';
import 'searchable_search_delegate.dart';
import 'widgets/add_food_dialog.dart';
import 'widgets/food_search_results_list_view.dart';

class FoodSearchDelegate extends SearchableSearchDelegate<Food> {
  final FoodSearchBloc foodBloc;
  final String noResultsMessage = 'No matches found.\nNeed something special?\nCreate a custom food!';

  FoodSearchDelegate({required this.foodBloc, required void Function(Food) onSelect})
      : super(onSelect: onSelect, searchFieldLabel: 'Search for food');

  @override
  Widget buildResults(BuildContext context) {
    foodBloc.add(StreamFoodQuery(query));
    return buildList(context, foodBloc);
  }

  Widget buildAddFab(BuildContext context) {
    return AddFloatingActionButton(onPressed: () async {
      final foodBloc = context.read<FoodSearchBloc>();

      final foodName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AddFoodDialog(initialFoodName: query),
      );

      if (foodName != null) {
        foodBloc.add(CreateCustomFood(foodName));
        query = foodName;
      }
    });
  }

  Widget buildList(BuildContext context, FoodSearchBloc foodBloc) {
    return BlocBuilder<FoodSearchBloc, FoodSearchState>(
      bloc: foodBloc,
      builder: (BuildContext context, FoodSearchState state) {
        if (query.isEmpty) {
          return Column(children: const []);
        }
        if (state is FoodSearchLoaded) {
          final items = state.items;
          return GLScaffold(
            floatingActionButton: buildAddFab(context),
            body: FoodSearchResultsListView(
              foods: items,
              onTap: (result) {
                closeSearch(context);
                onSelect(result);
              },
            ),
          );
        }
        if (state is NoFoodsFound) {
          return GLScaffold(
            floatingActionButton: buildAddFab(context),
            body: FabGuide(message: noResultsMessage),
          );
        }
        if (state is FoodSearchLoading) {
          return GLScaffold(
            floatingActionButton: buildAddFab(context),
            body: LoadingPage(),
          );
        }
        if (state is FoodSearchError) {
          return ErrorPage(message: state.message);
        }
        return const ErrorPage();
      },
    );
  }
}
