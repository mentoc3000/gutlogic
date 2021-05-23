import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food/food.dart';
import '../../../models/food/custom_food.dart';
import '../../../models/food/food.dart';
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
    final sensitivityIndicator =
        food.pantryEntryReference != null ? SensitivityIndicator(food.pantryEntryReference!.sensitivity) : null;

    return SearchResultTile(
      searchable: food,
      trailing: sensitivityIndicator,
      onTap: onTap,
      onDelete: (food) {
        if (food is CustomFood) context.read<FoodBloc>().add(DeleteCustomFood(food));
      },
      isCustom: food is CustomFood,
    );
  }
}
