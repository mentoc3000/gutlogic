import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/meal_entry/meal_entry.dart';
import '../../../models/diary_entry/meal_entry.dart';
import '../../../models/meal_element.dart';
import '../../../resources/sensitivity/sensitivity_service.dart';
import '../../../widgets/alert_dialogs/confirm_delete_dialog.dart';
import '../../../widgets/dismissible/delete_dismissible.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';
import '../../../widgets/sensitivity_indicator.dart';

class MealElementListTile extends StatelessWidget {
  final MealEntry mealEntry;
  final MealElement mealElement;
  final void Function() onTap;

  const MealElementListTile({
    required this.mealElement,
    required this.mealEntry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mealElementSensitivityLevel = context.select((SensitivityService sensitivity) {
      return sensitivity.of(mealElement.foodReference).level;
    });

    return DeleteDismissible(
      child: PushListTile(
        heading: mealElement.foodReference.name,
        // subheading: mealElement.foodReference.irritants.map((i) => i.name).join(', '),
        onTap: onTap,
        trailing: SensitivityIndicator(mealElementSensitivityLevel),
      ),
      onDelete: () =>
          context.read<MealEntryBloc>().add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealElement)),
      confirmDismiss: (_) => showDialog(
        context: context,
        builder: (_) => ConfirmDeleteDialog(itemName: mealElement.foodReference.name),
      ),
    );
  }
}
