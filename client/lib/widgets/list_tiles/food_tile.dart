import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/irritant/intensity.dart';
import '../../resources/sensitivity/sensitivity_service.dart';
import '../../routes/routes.dart';
import '../irritant_intensity/intensity_indicator.dart';
import '../sensitivity_indicator.dart';
import 'push_list_tile.dart';

class FoodTile extends StatelessWidget {
  final FoodReference food;
  final Intensity? intensity;
  final void Function()? onTap;

  const FoodTile({Key? key, required this.food, this.intensity, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(food);
    });

    return PushListTile(
      heading: food.searchHeading(),
      leading: SensitivityIndicator(sensitivity),
      trailing: IntensityIndicator(intensity),
      onTap: onTap ?? () => Navigator.push(context, Routes.of(context).createFoodPageRoute(food)),
    );
  }
}
