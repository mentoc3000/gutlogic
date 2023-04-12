import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/meal_element/meal_element.dart';
import '../../../models/food/food.dart';
import '../../../models/meal_element.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/cards/ingredients_card.dart';
import '../../../widgets/cards/irritants_card.dart';
import '../../../widgets/cards/notes_card.dart';
import '../../../widgets/cards/sensitivity_card.dart';
import '../../../widgets/cards/similar_foods_card.dart';
import 'quantity_card.dart';

class MealElementEntryListView extends StatelessWidget {
  final MealElement mealElement;
  final Food? food;
  final TextEditingController notesController;
  final TextEditingController amountController;
  final TextEditingController unitController;

  const MealElementEntryListView({
    Key? key,
    required this.mealElement,
    required this.food,
    required this.notesController,
    required this.amountController,
    required this.unitController,
  }) : super(key: key);

  void addFoodToPantry(BuildContext context) {
    Navigator.push(context, Routes.of(context).createPantryEntryPageRouteForFood(mealElement.foodReference));
  }

  @override
  Widget build(BuildContext context) {
    final mealElementSensitivity = context.select((SensitivityService sensitivity) {
      return sensitivity.of(mealElement.foodReference);
    });
    final hasIrritants =
        food?.irritants != null && food!.irritants!.fold<double>(0.0, (acc, el) => acc + el.concentration) > 0;

    final cards = [
      QuantityCard(
        quantity: mealElement.quantity,
        onChanged: (quantity) => context.read<MealElementBloc>().add(UpdateQuantity(quantity)),
        unitController: unitController,
        amountController: amountController,
        measureOptions: food?.measures,
      ),
      SensitivityCard(
        sensitivity: mealElementSensitivity,
        onTap: () => addFoodToPantry(context),
      ),
      if (food?.irritants != null) IrritantsCard(irritants: food!.irritants!),
      if (food?.ingredients != null && food!.ingredients!.isNotEmpty) IngredientsCard(ingredients: food!.ingredients!),
      if (hasIrritants && food != null) SimilarFoodsCard(food: food!.toFoodReference()),
      NotesCard(
        controller: notesController,
        onChanged: (notes) => context.read<MealElementBloc>().add(UpdateNotes(notes)),
      ),
    ];

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(padding: const EdgeInsets.all(1.0), child: cards[index]);
      },
    );
  }
}
