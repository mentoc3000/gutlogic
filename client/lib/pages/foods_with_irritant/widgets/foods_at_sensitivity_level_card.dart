import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../../models/food_reference/food_reference.dart';
import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../widgets/cards/expansion_card.dart';
import '../../../widgets/list_tiles/food_tile.dart';

class FoodsAtSensitivityLevelCard extends StatelessWidget {
  final SensitivityLevel sensitivityLevel;
  final Iterable<FoodReference> foods;

  const FoodsAtSensitivityLevelCard({super.key, required this.sensitivityLevel, required this.foods});

  @override
  Widget build(BuildContext context) {
    late final String heading;
    switch (sensitivityLevel) {
      case SensitivityLevel.none:
        heading = 'No sensitivity';
        break;
      case SensitivityLevel.mild:
        heading = 'Mild sensitivity';
        break;
      case SensitivityLevel.moderate:
        heading = 'Moderate sensitivity';
        break;
      case SensitivityLevel.severe:
        heading = 'Severe sensitivity';
        break;
      case SensitivityLevel.unknown:
        heading = 'Sensitivity unknown';
        break;
      default:
        throw ArgumentError(sensitivityLevel);
    }

    final tiles = foods.sortedBy((f) => f.name.toLowerCase()).map((f) => FoodTile(food: f)).toList();

    return ExpansionCard(
      heading: heading,
      initiallyExpanded: true,
      items: tiles,
    );
  }
}
