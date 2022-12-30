import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:gutlogic/widgets/irritant_warning.dart';

import '../../../blocs/food_search/food_search.dart';
import '../../../blocs/foods_suggestion/foods_suggestion.dart';
import '../../../models/food/ingredient.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/irritant_intensity/intensity_indicator.dart';
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

    final maxIntensity = context.select((IrritantService irritantService) {
      return irritantService.ofIngredient(ingredient).then((value) => value != null
          ? irritantService.maxIntensity(IrritantService.doseMap(value))
          : Future.value(Intensity.unknown));
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
      trailing: FutureBuilder<Intensity>(
        future: maxIntensity,
        builder: (context, snapshot) {
          final maxIntensity = snapshot.data;
          if (snapshot.hasData && maxIntensity != null) {
            if (ingredient.ingredients == null) {
              // Simple ingredient
              return IntensityIndicator(snapshot.data!);
            } else if (maxIntensity > Intensity.none) {
              // Nested ingredient with some irritant intensity
              return IrritantWarning();
            } else {
              // Nested ingredient with no known irritant intensity
              return Container();
            }
          } else {
            return Container();
          }
        },
      ),
      onTap: onTap,
    );
  }
}
