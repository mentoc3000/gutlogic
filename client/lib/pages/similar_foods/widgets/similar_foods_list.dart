import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../../models/food_reference/food_reference.dart';
import '../../../util/widget_utils.dart';
import 'similar_food_tile.dart';

class SimilarFoodsList extends StatelessWidget {
  final BuiltList<FoodReference> foods;
  final BuiltMap<FoodReference, int?> maxIntensities;

  const SimilarFoodsList({Key? key, required this.foods, required this.maxIntensities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tiles = foods.map((e) => SimilarFoodTile(food: e, maxIntensity: maxIntensities[e]));
    final separatedTiles = WidgetUtils.separate(tiles, separator: const Divider(color: Colors.grey));
    return ListView(children: separatedTiles);
  }
}
