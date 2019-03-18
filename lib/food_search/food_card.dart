import 'package:flutter/material.dart';
import 'package:gi_bliss/model/food.dart';
import 'package:gi_bliss/generic_widgets/itemCardLarge.dart';

class FoodCard extends StatelessWidget {
  final Food food;

  FoodCard(this.food);

  @override
  Widget build(BuildContext context) {
    return new ItemCardLarge(food.name, food.irritants.join(', '));
  }

}