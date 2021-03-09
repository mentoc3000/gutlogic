import 'package:flutter/widgets.dart';

import '../../../models/diary_entry/meal_entry.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/sensitivity_indicator.dart';
import 'diary_entry_list_tile.dart';

class MealEntryListTile extends StatelessWidget {
  final MealEntry entry;

  const MealEntryListTile({@required this.entry});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Meal/Snack',
      subheadings: entry.mealElements.map((e) => e.foodReference.name),
      diaryEntry: entry,
      barColor: GLColors.food,
      onTap: () => Navigator.push(context, Routes.of(context).createMealEntryRoute(entry: entry)),
      trailing: SensitivityIndicator(entry.getSensitivity()),
    );
  }
}
