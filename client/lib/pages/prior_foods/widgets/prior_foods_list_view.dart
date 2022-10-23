import 'package:flutter/material.dart';

import '../../../models/food_reference/food_reference.dart';
import '../../../style/gl_text_style.dart';
import 'prior_food_tile.dart';

class PriorFoodsListView extends StatelessWidget {
  final Iterable<FoodReference> recentFoods;

  const PriorFoodsListView({Key? key, required this.recentFoods}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final List<Widget> tiles;
    if (recentFoods.isEmpty) {
      tiles = [
        const ListTile(
          title: Text(
            'No foods have recently been logged in the Timeline',
            style: tileSubheadingStyle,
            textAlign: TextAlign.center,
          ),
        )
      ];
    } else {
      tiles = recentFoods.map((e) => PriorFoodTile(food: e)).toList();
    }

    return ListView.builder(
      itemCount: tiles.length,
      shrinkWrap: true,
      itemBuilder: (context, idx) => tiles[idx],
    );
  }
}
