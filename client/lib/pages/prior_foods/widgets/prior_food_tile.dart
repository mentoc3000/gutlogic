import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food_reference/food_reference.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';
import '../../../widgets/sensitivity_indicator.dart';

class PriorFoodTile extends StatelessWidget {
  final FoodReference food;

  const PriorFoodTile({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(food);
    });

    return PushListTile(
      heading: food.searchHeading(),
      leading: SensitivityIndicator(sensitivity),
      onTap: () => Navigator.push(context, Routes.of(context).createFoodPageRoute(food)),
    );
  }
}
