import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food/ingredient.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';
import '../../../widgets/sensitivity_indicator.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientTile({Key? key, required this.ingredient}) : super(key: key);

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
      onTap = null;
    }

    return PushListTile(
      heading: ingredient.name,
      leading: SensitivityIndicator(sensitivity),
      onTap: onTap,
    );
  }
}
