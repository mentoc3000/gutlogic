import 'package:flutter/widgets.dart';
import '../../../models/diary_entry/meal_entry.dart';
import '../../../models/meal_element.dart';
import '../../../routes/routes.dart';
import '../../../widgets/cards/list_card.dart';

import 'meal_element_list_tile.dart';

class MealElementsCard extends StatelessWidget {
  final MealEntry mealEntry;

  const MealElementsCard({Key key, @required this.mealEntry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> mealElementTiles(MealEntry entry) {
      return entry.mealElements.map((MealElement mealElement) {
        return MealElementListTile(
          mealElement: mealElement,
          mealEntry: entry,
          onTap: () {
            // Tells any currently focused widget to unfocus, so that it won't scroll when returning to this page.
            FocusManager.instance.primaryFocus.unfocus();
            return Navigator.push(context, Routes.of(context).createMealElementPageRoute(mealElement: mealElement));
          },
        );
      }).toList();
    }

    return ListCard(
      heading: 'Ingredients',
      items: mealElementTiles(mealEntry),
    );
  }
}
