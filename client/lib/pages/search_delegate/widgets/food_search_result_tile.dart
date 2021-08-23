import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food/food.dart';
import '../../../models/food/custom_food.dart';
import '../../../models/food/food.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../widgets/sensitivity_indicator.dart';
import 'search_result_tile.dart';

class FoodSearchResultTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;

  const FoodSearchResultTile({
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foodSensitivityLevel = context.select((SensitivityService sensitivity) {
      return sensitivity.of(food.toFoodReference()).level;
    });

    return SearchResultTile(
      searchable: food,
      trailing: SensitivityIndicator(foodSensitivityLevel),
      onTap: onTap,
      onDelete: (food) {
        if (food is CustomFood) context.read<FoodBloc>().add(DeleteCustomFood(food));
      },
      isCustom: food is CustomFood,
    );
  }
}
