import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_search/food_search.dart';
import '../../models/food/custom_food.dart';
import '../../models/food/food.dart';
import '../../resources/sensitivity/sensitivity_service.dart';
import '../sensitivity_indicator.dart';
import 'searchable_tile.dart';

class FoodSearchResultTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;

  const FoodSearchResultTile({
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foodSensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(food.toFoodReference());
    });

    return SearchableTile(
      searchable: food,
      leading: SensitivityIndicator(foodSensitivity),
      onTap: onTap,
      onDelete: (food) {
        if (food is CustomFood) context.read<FoodSearchBloc>().add(DeleteCustomFood(food));
      },
      isCustom: food is CustomFood,
    );
  }
}
