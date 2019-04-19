import 'food.dart';
import 'quantity.dart';

class Ingredient {
  Food food;
  Quantity quantity;

  Ingredient({
    this.food,
    this.quantity
  });

  factory Ingredient.copy(Ingredient original) {
    return Ingredient(
      food: original.food,
      quantity: original.quantity
    );
  }
}