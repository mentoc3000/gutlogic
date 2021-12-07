import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food_reference/food_reference.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';
import '../../../widgets/sensitivity_indicator.dart';

class FoodListTile extends StatelessWidget {
  final FoodReference foodReference;

  const FoodListTile({Key? key, required this.foodReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(foodReference);
    });

    return PushListTile(
      heading: foodReference.searchHeading(),
      trailing: SensitivityIndicator(sensitivity),
      onTap: () => Navigator.push(context, Routes.of(context).createFoodPageRoute(foodReference)),
    );
  }
}
