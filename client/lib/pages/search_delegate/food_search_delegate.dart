import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_search/food_search.dart';
import '../../blocs/foods_suggestion/foods_suggestion.dart';
import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import '../../widgets/fab_guide.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/barcode_scan_icon_button.dart';
import '../../widgets/powered_by_edamam.dart';
import 'searchable_search_delegate.dart';
import 'widgets/add_food_dialog.dart';
import 'widgets/food_reference_suggestion_tile.dart';
import '../../widgets/list_tiles/food_search_result_tile.dart';

class FoodSearchDelegate extends SearchableSearchDelegate<FoodReference> {
  final FoodSearchBloc foodSearchBloc;
  final FoodSuggestionCubit foodSuggestionCubit;
  final String noResultsMessage = 'No matches found.\nNeed something special?\nCreate a custom food!';

  FoodSearchDelegate({
    required this.foodSearchBloc,
    required this.foodSuggestionCubit,
    required void Function(FoodReference) onSelect,
  }) : super(onSelect: onSelect, searchFieldLabel: 'Search for food') {
    foodSuggestionCubit.update();
    foodSearchBloc.add(StreamFoodQuery(query));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final clear = clearActionButton();
    final scan = BarcodeScanIconButton(
      onFood: (food) {
        onSelect(food.toFoodReference());
      },
    );
    return [clear, scan];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocProvider.value(
      value: foodSuggestionCubit,
      child: BlocBuilder<FoodSuggestionCubit, FoodsSuggestionState>(
        builder: (BuildContext context, FoodsSuggestionState state) {
          if (state is FoodsSuggestionLoaded) {
            return buildSuggestionList(context, state.suggestedFoods);
          }
          if (state is FoodsSuggestionLoading) {
            return buildLoadingPage(context);
          }
          if (state is FoodsSuggestionError) {
            return GLErrorWidget(message: state.message);
          }
          return const GLErrorWidget();
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    foodSearchBloc.add(StreamFoodQuery(query));

    return BlocBuilder<FoodSearchBloc, FoodSearchState>(
      bloc: foodSearchBloc,
      builder: (BuildContext context, FoodSearchState state) {
        if (query.isEmpty) {
          return const Column(children: []);
        }
        if (state is FoodSearchLoaded) {
          final items = state.items;
          return buildResultList(context, items);
        }
        if (state is NoFoodsFound) {
          return buildNoResults(context);
        }
        if (state is FoodSearchLoading) {
          return GLScaffold(
            floatingActionButton: buildAddFab(context),
            body: GLLoadingWidget(),
          );
        }
        if (state is FoodSearchError) {
          return GLErrorWidget(message: state.message);
        }
        return const GLErrorWidget();
      },
    );
  }

  GLScaffold buildNoResults(BuildContext context) {
    return GLScaffold(
      floatingActionButton: buildAddFab(context),
      body: FabGuide(message: noResultsMessage),
    );
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

  GLScaffold buildLoadingPage(BuildContext context) {
    return GLScaffold(
      floatingActionButton: buildAddFab(context),
      body: GLLoadingWidget(),
    );
  }

  Widget buildList({
    required BuildContext context,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return GLScaffold(
      floatingActionButton: buildAddFab(context),
      body: SafeArea(
        child: PoweredByEdamam(
          child: ListView.builder(
            itemCount: itemCount,
            shrinkWrap: true,
            itemBuilder: itemBuilder,
          ),
        ),
      ),
    );
  }

  Widget buildResultList(BuildContext context, BuiltList<Food> foods) {
    return buildList(
      context: context,
      itemCount: foods.length,
      itemBuilder: (BuildContext context, int index) {
        final result = foods[index];
        return FoodSearchResultTile(
          food: result,
          onTap: () {
            closeSearch(context);
            onSelect(result.toFoodReference());
          },
        );
      },
    );
  }

  Widget buildSuggestionList(BuildContext context, BuiltList<FoodReference> foodReferences) {
    return buildList(
      context: context,
      itemCount: foodReferences.length,
      itemBuilder: (BuildContext context, int index) {
        final result = foodReferences[index];
        return FoodReferenceSuggestionTile(
          foodReference: result,
          onTap: () {
            closeSearch(context);
            onSelect(result);
          },
        );
      },
    );
  }
}
