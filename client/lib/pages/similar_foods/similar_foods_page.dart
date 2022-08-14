import 'package:flutter/material.dart';

import '../../models/food_reference/food_reference.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/similar_foods.dart';

class SimilarFoodsPage extends StatelessWidget {
  final FoodReference food;

  const SimilarFoodsPage({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Similar to ${food.name}'),
      body: SimilarFoods(food: food),
    );
  }
}
