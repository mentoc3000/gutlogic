import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';

class FoodAndDrinkTileLarge extends StatelessWidget {
  final MealEntry entry;

  FoodAndDrinkTileLarge({this.entry});
  
  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: entry.meal.name,
      subheading: entry.meal.ingredients.fold('', (value, element) => value + ', ' + element.food.name),
    );
  }

}

class BowelMovementTile extends StatelessWidget {
  final BowelMovementEntry entry;

  BowelMovementTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: 'Type ' + entry.bowelMovement.type.toString(), 
      subheading: 'Volume: ' + entry.bowelMovement.volume.toString()
    );
  }

}

class MedicineTile extends StatelessWidget {
  final MedicineEntry entry;

  MedicineTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: entry.medicine.name, 
      subheading: entry.dose
    );
  }

}