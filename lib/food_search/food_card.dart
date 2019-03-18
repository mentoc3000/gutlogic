import 'package:flutter/material.dart';
import 'package:gut_ai/model/food.dart';
import 'package:gut_ai/generic_widgets/item_card_large.dart';

class FoodCard extends StatelessWidget {
  final Food food;

  FoodCard(this.food);

  @override
  Widget build(BuildContext context) {
    return new ItemCardLarge(food.name, food.irritants.join(', '));
  }

}