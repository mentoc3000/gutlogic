import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/meal_entry/meal_entry.dart';
import '../../../models/diary_entry/meal_entry.dart';
import '../../../models/meal_element.dart';
import '../../../widgets/gl_swipeable.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';

class MealElementListTile extends StatelessWidget {
  final MealEntry mealEntry;
  final MealElement mealElement;
  final void Function() onTap;

  const MealElementListTile({@required this.mealElement, @required this.mealEntry, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mealEntryBloc = context.bloc<MealEntryBloc>();
    return GLSwipeable(
      child: PushListTile(
        heading: mealElement.foodReference.name,
        // subheading: mealElement.foodReference.irritants.map((i) => i.name).join(', '),
        onTap: onTap,
      ),
      onDelete: () => mealEntryBloc.add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealElement)),
    );
  }
}
