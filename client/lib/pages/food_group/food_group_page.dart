import 'package:flutter/material.dart';

import '../../models/food_group.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/food_list_tile.dart';

class FoodGroupPage extends StatelessWidget {
  final FoodGroup foodGroup;

  const FoodGroupPage({Key? key, required this.foodGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedFoods = foodGroup.foodRefs.toList()..sort((a, b) => a.name.compareTo(b.name));
    final tiles = sortedFoods.map((e) => FoodListTile(foodReference: e)).toList();

    return GLScaffold(
      appBar: GLAppBar(title: foodGroup.name),
      body: ListView(children: tiles),
    );
  }
}
