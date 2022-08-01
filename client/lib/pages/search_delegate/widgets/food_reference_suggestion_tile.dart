import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food/custom_food.dart';
import '../../../models/food_reference/food_reference.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../widgets/sensitivity_indicator.dart';
import 'search_result_tile.dart';

class FoodReferenceSuggestionTile extends StatelessWidget {
  final FoodReference foodReference;
  final VoidCallback onTap;

  const FoodReferenceSuggestionTile({
    required this.foodReference,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foodSensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(foodReference);
    });

    return SearchResultTile(
      searchable: foodReference,
      leading: SensitivityIndicator(foodSensitivity),
      onTap: onTap,
      isCustom: foodReference is CustomFood,
    );
  }
}
