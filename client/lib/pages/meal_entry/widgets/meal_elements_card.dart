import 'package:flutter/widgets.dart';

import '../../../models/diary_entry/meal_entry.dart';
import '../../../models/meal_element.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/cards/list_card.dart';
import 'meal_element_list_tile.dart';

class MealElementsCard extends StatelessWidget {
  final MealEntry mealEntry;
  final VoidCallback onAdd;

  const MealElementsCard({Key? key, required this.mealEntry, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgets = mealEntry.mealElements.map<Widget>((MealElement mealElement) {
      return MealElementListTile(
        mealElement: mealElement,
        mealEntry: mealEntry,
        onTap: () {
          // Tells any currently focused widget to unfocus, so that it won't scroll when returning to this page.
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(context, Routes.of(context).createMealElementPageRoute(mealElement: mealElement));
        },
      );
    }).toList();
    widgets.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: GLPrimaryButton(
        onPressed: onAdd,
        child: const StretchedButtonContent(label: 'Add Food or Drink'),
      ),
    ));

    return ListCard(
      heading: 'Food & Drink',
      items: widgets,
    );
  }
}
