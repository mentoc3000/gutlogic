import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/item_tile.dart';
import 'ingredient_entry_page.dart';
import '../widgets/datetime_view.dart';
import '../models/ingredient.dart';
import '../widgets/gutai_card.dart';
import '../widgets/notes_tile.dart';
import '../widgets/placeholder_widget.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'meal-entry-page';

  final MealEntry entry;
  final void Function(MealEntry) onUpdate;

  MealEntryPage({this.entry, this.onUpdate});

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PlaceholderWidget(Colors.orange);
  }
  // MealEntry _entry;

  // void deleteIngredient(Ingredient ingredient) {
  //   setState(() {
  //     _entry.meal.ingredients.remove(ingredient);
  //   });
  //   widget.onUpdate(_entry);
  // }

  // void addIngredient() {
  //   Ingredient newIngredient = Ingredient();
  //   _entry.meal.ingredients.add(newIngredient);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => IngredientEntryPage(ingredient: newIngredient),
  //     ),
  //   );
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _entry = widget.entry;
  // }

  // @override
  // Widget build(BuildContext context) {
  //   List<Widget> ingredientTiles = _entry.meal.ingredients.map((i) {
  //     return Dismissible(
  //       key: ObjectKey(i),
  //       child: IngredientTile(
  //           ingredient: i,
  //           mealEntry: _entry,
  //           onTap: () => Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => IngredientEntryPage(ingredient: i)),
  //               )),
  //       onDismissed: (direction) {
  //         if (direction == DismissDirection.endToStart) {
  //           deleteIngredient(i);
  //           Scaffold.of(context).showSnackBar(
  //               SnackBar(content: Text("${i.food.name} removed.")));
  //         }
  //       },
  //       background: Container(
  //         alignment: Alignment.centerRight,
  //         padding: EdgeInsets.only(right: 20.0),
  //         color: Colors.red,
  //         child: Icon(
  //           Icons.delete,
  //           color: Colors.white,
  //         ),
  //       ),
  //     );
  //   }).toList();

  //   List<Widget> items = [
  //     DatetimeView(date: _entry.dateTime),
  //     GutAICard(
  //       child: Column(
  //         children: [
  //           HeaderListTile(
  //             heading: 'Ingredients',
  //           )
  //         ]..addAll(ingredientTiles),
  //       ),
  //     ),
  //     NotesTile(notes: _entry.notes)
  //   ];

  //   return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: Text(_entry.meal.name ?? 'Meal'),
  //     ),
  //     body: ListView.builder(
  //       itemCount: items.length,
  //       itemBuilder: (context, index) =>
  //           Padding(padding: EdgeInsets.all(1.0), child: items[index]),
  //       padding: EdgeInsets.all(0.0),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //         child: Icon(Icons.add), onPressed: addIngredient),
  //   );
  // }
}
