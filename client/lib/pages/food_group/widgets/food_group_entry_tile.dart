import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food_group_entry.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/irritant_intensity/intensity_indicator.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';
import '../../../widgets/sensitivity_indicator.dart';

class FoodGroupEntryTile extends StatelessWidget {
  final FoodGroupEntry entry;
  final int? maxIntensity;
  final void Function()? onTap;

  const FoodGroupEntryTile({Key? key, required this.entry, required this.maxIntensity, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(entry.foodRef);
    });

    return PushListTile(
      heading: entry.foodRef.searchHeading(),
      leading: SensitivityIndicator(sensitivity),
      trailing: IntensityIndicator(maxIntensity),
      onTap: () => Navigator.push(context, Routes.of(context).createFoodPageRoute(entry.foodRef)),
    );
  }
}
