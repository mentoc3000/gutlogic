import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:gutlogic/models/irritant/intensity.dart';

import '../../../models/food_group_entry.dart';
import '../../../routes/routes.dart';
import '../../../util/widget_utils.dart';
import 'food_group_entry_tile.dart';

class FoodGroupList extends StatelessWidget {
  final Iterable<FoodGroupEntry> foods;
  final BuiltMap<FoodGroupEntry, Intensity> maxIntensities;

  const FoodGroupList({Key? key, required this.foods, required this.maxIntensities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedFoods = foods.toList()..sort((a, b) => a.foodRef.name.compareTo(b.foodRef.name));
    final tiles = sortedFoods.map((e) => FoodGroupEntryTile(
          entry: e,
          maxIntensity: maxIntensities[e] ?? Intensity.none,
          onTap: () => Navigator.push(context, Routes.of(context).createFoodPageRoute(e.foodRef)),
        ));
    final separatedTiles = WidgetUtils.separate(tiles, separator: const Divider(color: Colors.grey));
    separatedTiles.add(const SizedBox(height: 72));
    return ListView(children: separatedTiles);
  }
}
