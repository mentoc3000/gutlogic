import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food_search/food_search.dart';
import '../../../blocs/foods_suggestion/foods_suggestion.dart';
import '../../../models/food/ingredient.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';
import '../../../widgets/sensitivity_indicator.dart';
import '../../search_delegate/food_search_delegate.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientTile({Key? key, required this.ingredient}) : super(key: key);

  void showFoodSearch(BuildContext context, String query) {
    final foodSearchBloc = BlocProvider.of<FoodSearchBloc>(context);
    final recentFoodsCubit = RecentFoodsCubit.fromContext(context);

    final foodSearchDelegate = FoodSearchDelegate(
      foodSearchBloc: foodSearchBloc,
      foodSuggestionCubit: recentFoodsCubit,
      onSelect: (food) => Navigator.push(context, Routes.of(context).createFoodPageRoute(food)),
    );

    showSearch(
      context: context,
      query: query,
      delegate: foodSearchDelegate,
    );

    foodSearchDelegate.showResults(context);
  }

  @override
  Widget build(BuildContext context) {
    final sensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(ingredient.foodReference);
    });

    late final VoidCallback? onTap;
    if (ingredient.foodReference != null) {
      onTap = () => Navigator.push(context, Routes.of(context).createFoodPageRoute(ingredient.foodReference!));
    } else if (ingredient.ingredients != null) {
      onTap = () =>
          Navigator.push(context, Routes.of(context).createIngredientsPageRoute(ingredients: ingredient.ingredients!));
    } else {
      onTap = () => showFoodSearch(context, ingredient.name);
    }

    return PushListTile(
      heading: ingredient.name,
      leading: SensitivityIndicator(sensitivity),
      onTap: onTap,
    );
  }
}
