import 'package:flutter/material.dart';
import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/genericViews/itemCardLarge.dart';

class FoodCard extends StatelessWidget {
  final Food food;

  FoodCard(this.food);

  @override
  Widget build(BuildContext context) {
    return new ItemCardLarge(food.name, food.irritants.join(', '));
  }

}