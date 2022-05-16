import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/food/food.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/cards/irritants_card.dart';
import '../../../widgets/cards/sensitivity_card.dart';

class FoodListView extends StatelessWidget {
  final Food food;

  const FoodListView({Key? key, required this.food}) : super(key: key);

  void addFoodToPantry(BuildContext context) {
    Navigator.push(context, Routes.of(context).createPantryEntryPageRouteForFood(food.toFoodReference()));
  }

  @override
  Widget build(BuildContext context) {
    final sensitivity = Future.value(context.read<SensitivityService>().of(food.toFoodReference()));

    final cards = [
      SensitivityCard(
        sensitivity: sensitivity,
        onTap: () => addFoodToPantry(context),
      ),
      IrritantsCard(foodReference: food.toFoodReference()),
    ];

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) =>
          Padding(padding: const EdgeInsets.all(1.0), child: cards[index]),
    );
  }
}
