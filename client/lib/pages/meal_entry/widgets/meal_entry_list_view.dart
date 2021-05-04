import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food/food.dart';
import '../../../blocs/meal_entry/meal_entry.dart';
import '../../../models/diary_entry/meal_entry.dart';
import '../../../widgets/cards/datetime_card.dart';
import '../../../widgets/cards/notes_card.dart';
import '../../search_delegate/food_search_delegate.dart';
import 'meal_elements_card.dart';

class MealEntryListView extends StatelessWidget {
  final MealEntry mealEntry;
  final TextEditingController notesController;

  const MealEntryListView({Key? key, required this.mealEntry, required this.notesController}) : super(key: key);

  void addMealElement(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodBloc>(context);
    final mealEntryBloc = context.read<MealEntryBloc>();

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        onSelect: (food) => mealEntryBloc.add(AddMealElement(food)),
      ),
    );
  }

  List<Widget> buildCards(BuildContext context, MealEntry entry) {
    return [
      DateTimeCard(
        dateTime: entry.datetime,
        onChanged: (DateTime? datetime) {
          if (datetime == null) return;
          context.read<MealEntryBloc>().add(UpdateMealEntryDateTime(datetime));
        },
      ),
      MealElementsCard(
        mealEntry: entry,
        onAdd: () => addMealElement(context),
      ),
      NotesCard(
        controller: notesController,
        onChanged: (String notes) {
          context.read<MealEntryBloc>().add(UpdateMealEntryNotes(notes));
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cards = buildCards(context, mealEntry);
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) =>
          Padding(padding: const EdgeInsets.all(1.0), child: cards[index]),
      padding: const EdgeInsets.all(0.0),
    );
  }
}
