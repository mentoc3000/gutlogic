import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/pantry_entry/pantry_entry.dart';
import '../../../models/food/food.dart';
import '../../../models/pantry/pantry_entry.dart';
import '../../../widgets/cards/food_details_card.dart';
import '../../../widgets/cards/notes_card.dart';
import 'sensitivity_slider_card.dart';

class PantryEntryListView extends StatelessWidget {
  final PantryEntry pantryEntry;
  final Food? food;
  final TextEditingController notesController;

  const PantryEntryListView({
    Key? key,
    required this.pantryEntry,
    required this.food,
    required this.notesController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pantryBloc = context.read<PantryEntryBloc>();

    final cards = [
      SensitivitySlider(
        sensitivityLevel: pantryEntry.sensitivity.level,
        onChanged: (sensitivityLevel) => pantryBloc.add(UpdateSensitivityLevel(sensitivityLevel)),
      ),
      if (food != null) FoodDetailsCard(food: food!),
      NotesCard(
        controller: notesController,
        onChanged: (notes) => context.read<PantryEntryBloc>().add(UpdateNotes(notes)),
      ),
    ];

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) =>
          Padding(padding: const EdgeInsets.all(1.0), child: cards[index]),
    );
  }
}
