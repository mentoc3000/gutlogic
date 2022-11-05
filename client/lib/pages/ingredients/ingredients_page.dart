import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../models/food/ingredient.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/ingredients_list.dart';

class IngredientsPage extends StatelessWidget {
  final BuiltList<Ingredient> ingredients;

  const IngredientsPage({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Ingredients'),
      body: IngredientsList(ingredients: ingredients),
    );
  }
}
