import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import '../../../models/pantry/pantry_entry.dart';
import '../../../widgets/list_tiles/pantry_list_tile.dart';

class PantryListView extends StatelessWidget {
  final BuiltList<PantryEntry> pantryEntries;

  const PantryListView({Key? key, required this.pantryEntries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pantryEntries.length,
      itemBuilder: (BuildContext context, int index) => PantryListTile(pantryEntry: pantryEntries[index]),
    );
  }
}
