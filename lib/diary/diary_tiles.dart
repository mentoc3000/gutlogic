import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';

class FoodAndDrinkTileLarge extends ItemTileLarge {
  final MealEntry entry;

  FoodAndDrinkTileLarge({this.entry}):
    super(
      heading: entry.meal.name, 
      subheading: entry.meal.ingredients.fold('', (value, element) => value + ', ' + element.food.name)
    );

}

class BowelMovementTile extends ItemTileLarge {
  final BowelMovementEntry entry;

  BowelMovementTile({this.entry}):
    super(
      heading: 'Type ' + entry.bowelMovement.type.toString(), 
      subheading: 'Volume: ' + entry.bowelMovement.volume.toString()
    );

}

class MedicineTile extends ItemTileLarge {
  final MedicineEntry entry;

  MedicineTile({this.entry}):
    super(
      heading: entry.medicine.name, 
      subheading: entry.dose
    );

}