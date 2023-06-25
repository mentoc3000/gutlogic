import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food/food.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/cards/ingredients_card.dart';
import '../../../widgets/cards/irritants_card.dart';
import '../../../widgets/cards/sensitivity_card.dart';
import '../../../widgets/cards/similar_foods_card.dart';

class FoodListView extends StatelessWidget {
  final Food food;
  final BuiltSet<String> excludedIrritants;

  const FoodListView({Key? key, required this.food, required this.excludedIrritants}) : super(key: key);

  void addFoodToPantry(BuildContext context) {
    Navigator.push(context, Routes.of(context).createPantryEntryPageRouteForFood(food.toFoodReference()));
  }

  @override
  Widget build(BuildContext context) {
    final sensitivity = context.watch<SensitivityService>().of(food.toFoodReference());
    final hasIrritants =
        food.irritants != null && food.irritants!.fold<double>(0.0, (acc, el) => acc + el.concentration) > 0;

    final cards = [
      SensitivityCard(sensitivity: sensitivity, onTap: () => addFoodToPantry(context)),
      if (food.irritants != null) IrritantsCard(irritants: food.irritants!, excludedIrritants: excludedIrritants),
      if (food.ingredients != null && food.ingredients!.isNotEmpty) IngredientsCard(ingredients: food.ingredients!),
      if (hasIrritants) SimilarFoodsCard(food: food.toFoodReference()),
    ];

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(padding: const EdgeInsets.all(1.0), child: cards[index]);
      },
    );
  }
}
