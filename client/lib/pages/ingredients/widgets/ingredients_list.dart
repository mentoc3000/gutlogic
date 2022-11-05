import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../../models/food/ingredient.dart';
import '../../../util/widget_utils.dart';
import 'ingredients_tile.dart';

class IngredientsList extends StatelessWidget {
  final BuiltList<Ingredient> ingredients;

  const IngredientsList({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tiles = ingredients.map((i) => IngredientTile(ingredient: i));
    final separatedTiles = WidgetUtils.separate(tiles, separator: const Divider(color: Colors.grey));
    return ListView(children: separatedTiles);
  }
}
