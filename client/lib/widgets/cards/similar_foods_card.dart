import 'package:flutter/material.dart';

import '../../models/food_reference/food_reference.dart';
import '../../routes/routes.dart';
import '../../style/gl_text_style.dart';
import 'push_card.dart';

class SimilarFoodsCard extends StatelessWidget {
  final FoodReference food;

  const SimilarFoodsCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return PushCard(
      child: const Text('Foods with similar irritants', style: tileHeadingStyle),
      onTap: () => Navigator.push(context, Routes.of(context).createSimilarFoodsRoute(food: food)),
    );
  }
}
