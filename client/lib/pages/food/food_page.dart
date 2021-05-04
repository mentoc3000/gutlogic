import 'package:flutter/widgets.dart';

import '../../models/food/food.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/nutrition_card.dart';
import 'widgets/overall_assessment_card.dart';

class FoodPage extends StatelessWidget {
  final Food food;

  const FoodPage({required this.food});

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: food.name),
      body: ListView(
        children: [
          OverallAssessmentCard(),
          // IrritantsAssessmentCard(irritants: food.irritants ?? []),
          NutritionCard(),
        ],
      ),
    );
  }
}
