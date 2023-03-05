import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../models/food_reference/food_reference.dart';
import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../widgets/sensitivity_level_pie_chart.dart';
import 'foods_at_sensitivity_level_card.dart';

class FoodsWithIrritantListView extends StatelessWidget {
  final BuiltMap<SensitivityLevel, int> sensitivityLevelCount;
  final BuiltMap<SensitivityLevel, BuiltList<FoodReference>> foodsBySensitivityLevel;

  const FoodsWithIrritantListView({required this.sensitivityLevelCount, required this.foodsBySensitivityLevel});

  @override
  Widget build(BuildContext context) {
    final pieChartRadius = MediaQuery.of(context).size.shortestSide / 4;
    final cards = foodsBySensitivityLevel.entries
        .where((element) => element.value.isNotEmpty) // only show sensitivity levels with foods in them
        .sortedBy<num>((element) => -element.key.toInt()) // sort from most to least severe
        .map((entry) => FoodsAtSensitivityLevelCard(sensitivityLevel: entry.key, foods: entry.value));

    return ListView(
      children: [
        SensitivityLevelPieChart(foodCount: sensitivityLevelCount, radius: pieChartRadius),
        ...cards,
      ],
    );
  }
}
