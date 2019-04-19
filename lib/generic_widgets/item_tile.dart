import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';
import 'package:gut_ai/model/food.dart';
import 'package:gut_ai/model/ingredient.dart';
import 'package:gut_ai/model/meal.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/food_search/food_sheet_page.dart';
import 'package:gut_ai/diary/ingredient_entry_page.dart';

class GutAIListTile extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget leading;
  final Function onTap;
  final double size;
  final bool dense;
  final Widget trailing;

  GutAIListTile({
    this.heading, 
    this.subheading, 
    this.sensitivity, 
    this.leading, 
    this.trailing, 
    this.onTap, 
    this.size, 
    this.dense=false});

  @override
  Widget build(BuildContext context) {
    Widget subheadingWidget;
    if (this.subheading == null) {
      subheadingWidget = null;
    } else {
      subheadingWidget = Text(this.subheading);
    }
    return new ListTile(
      title: Text(this.heading),
      subtitle: subheadingWidget,
      leading: this.leading,
      trailing: this.trailing,
      onTap: this.onTap,
      dense: this.dense,
    );
  }

}

class FoodListTile extends StatelessWidget {

  final Food food;

  FoodListTile({this.food});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile(
      heading: this.food.name,
      subheading: this.food.irritants.join(', '),
      trailing: Into(size: 30),
      size: 30, 
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FoodSheetPage(food: this.food)))
    );
  }
}

class IngredientTile extends StatelessWidget {

  final MealEntry mealEntry;
  final Ingredient ingredient;
  final Function onTap;

  IngredientTile({this.ingredient, this.mealEntry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile(
      heading: this.ingredient.food.name,
      subheading: this.ingredient.food.irritants.join(', '),
      trailing: Into(size: 30),
      size: 30, 
      onTap: onTap
    );
  }
}

class AdderListTile extends StatelessWidget {

  final String heading;
  final Function onTap;

  AdderListTile({this.heading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile(
      heading: this.heading,
      trailing: Adder(size: 30, onTap: onTap,),
      size: 30, 
    );
  }
}


class Adder extends StatelessWidget {

  final double size;
  final Function onTap;

  Adder({this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add, size: size),
      onPressed: onTap,
    );
  }
}

class Into extends StatelessWidget {

  final double size;
  final Function onTap;

  Into({this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.keyboard_arrow_right, size: size),
      onPressed: onTap,
    );
  }
}