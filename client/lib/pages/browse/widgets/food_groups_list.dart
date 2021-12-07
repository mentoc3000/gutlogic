import 'package:flutter/widgets.dart';

import '../../../models/food_group.dart';
import 'food_group_list_tile.dart';

class FoodGroupsList extends StatelessWidget {
  final Iterable<FoodGroup> foodGroups;
  const FoodGroupsList({Key? key, required this.foodGroups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedGroups = foodGroups.toList()..sort((a, b) => a.name.compareTo(b.name));
    final tiles = sortedGroups.map((e) => FoodGroupListTile(foodGroup: e)).toList();
    return ListView(children: tiles);
  }
}
