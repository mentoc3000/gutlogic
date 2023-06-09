import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_group_search/food_group_search.dart';
import '../../blocs/food_search/food_search.dart';
import '../../models/food/food.dart';
import '../../models/food_group_entry.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/irritant/intensity.dart';
import '../../style/gl_text_style.dart';
import '../../widgets/fab_guide.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/barcode_scan_icon_button.dart';
import '../../widgets/list_tiles/food_search_result_tile.dart';
import '../../widgets/list_tiles/food_tile.dart';
import '../../widgets/powered_by_edamam.dart';
import 'searchable_search_delegate.dart';
import 'widgets/add_food_dialog.dart';

class FoodGroupSearchDelegate extends SearchableSearchDelegate<FoodReference> {
  final FoodSearchBloc foodSearchBloc;
  final FoodGroupSearchCubit foodGroupSearchCubit;
  final String noResultsMessage = 'No matches found.\nNeed something special?\nCreate a custom food!';

  FoodGroupSearchDelegate({
    required this.foodSearchBloc,
    required this.foodGroupSearchCubit,
    required void Function(FoodReference) onSelect,
  }) : super(onSelect: onSelect, searchFieldLabel: 'Search for food') {
    foodGroupSearchCubit.query(query);
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
    foodGroupSearchCubit.query(query);

    return BlocBuilder<FoodGroupSearchCubit, FoodGroupSearchState>(
      bloc: foodGroupSearchCubit,
      builder: (BuildContext context, FoodGroupSearchState state) {
        if (state is FoodGroupSearchLoaded) {
          return buildSuggestionList(context, state.foods, state.maxIntensities);
        }
        if (state is FoodGroupSearchLoading) {
          return buildLoadingPage(context);
        }
        if (state is FoodGroupSearchError) {
          return GLErrorWidget(message: state.message);
        }
        return const GLErrorWidget();
      },
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

  Widget buildResultList(BuildContext context, BuiltList<Food> foods) {
    return GLScaffold(
      floatingActionButton: buildAddFab(context),
      body: SafeArea(
        child: PoweredByEdamam(
          child: ListView.builder(
            itemCount: foods.length,
            shrinkWrap: true,
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
          ),
        ),
      ),
    );
  }

  Widget buildSuggestionList(
    BuildContext context,
    BuiltList<FoodGroupEntry> foodGroupEntries,
    BuiltMap<FoodGroupEntry, Intensity> maxIntensities,
  ) {
    return GLScaffold(
      floatingActionButton: buildAddFab(context),
      body: SafeArea(
        child: ListView.builder(
          itemCount: foodGroupEntries.length + 1,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if (index < foodGroupEntries.length) {
              final result = foodGroupEntries[index];
              final maxIntensity = maxIntensities[result] ?? Intensity.none;
              return FoodTile(
                food: result.foodRef,
                intensity: maxIntensity,
                onTap: () {
                  closeSearch(context);
                  onSelect(result.foodRef);
                },
              );
            } else if (query.isNotEmpty) {
              // Show helper tile at bottom of suggestions, if a query has been entered
              return const ListTile(
                title: Text(
                  'Tap Search to find more foods',
                  style: tileSubheadingStyle,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
