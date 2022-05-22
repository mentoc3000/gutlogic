import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../../models/food_group_entry.dart';
import '../../../util/widget_utils.dart';
import 'food_group_entry_tile.dart';

class FoodGroupList extends StatelessWidget {
  final Iterable<FoodGroupEntry> foods;
  final BuiltMap<FoodGroupEntry, int?> maxIntensities;

  const FoodGroupList({Key? key, required this.foods, required this.maxIntensities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedFoods = foods.toList()..sort((a, b) => a.foodRef.name.compareTo(b.foodRef.name));
    final tiles = sortedFoods.map((e) => FoodGroupEntryTile(entry: e, maxIntensity: maxIntensities[e]));
    final separatedTiles = WidgetUtils.separate(tiles, separator: const Divider(color: Colors.grey));
    return ListView(children: separatedTiles);
  }
}
