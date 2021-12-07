import 'package:flutter/widgets.dart';

import '../../../models/food_group.dart';
import '../../../routes/routes.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';

class FoodGroupListTile extends StatelessWidget {
  final FoodGroup foodGroup;
  const FoodGroupListTile({Key? key, required this.foodGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PushListTile(
      heading: foodGroup.name,
      onTap: () => Navigator.of(context).push(Routes.of(context).createFoodGroupRoute(foodGroup)),
    );
  }
}
