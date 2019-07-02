import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:built_collection/built_collection.dart';
import '../models/diary_entry.dart';
import '../widgets/item_tile.dart';
import 'ingredient_entry_page.dart';
import '../widgets/datetime_view.dart';
import '../models/ingredient.dart';
import '../widgets/gutai_card.dart';
import '../widgets/notes_tile.dart';
import '../blocs/diary_entry_bloc.dart';
import '../blocs/database_event.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'meal-entry-page';

  final MealEntry entry;

  MealEntryPage({this.entry});

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {
  MealEntry _entry;

  void deleteIngredient(Ingredient ingredient) {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    setState(() {
      _entry = _entry.rebuild((b) => b.meal.ingredients.remove(ingredient));
    });
    diaryEntryBloc.dispatch(Update(_entry));
  }

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    List<Widget> ingredientTiles = _entry.meal.ingredients.map((ingredient) {
      return Dismissible(
        key: ObjectKey(ingredient),
        child: IngredientTile(
          ingredient: ingredient,
          mealEntry: _entry,
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientEntryPage(
                        ingredient: ingredient,
                        onSave: (newIngredient) {
                          //How to replace ingredient?
                          // Replace old ingredient with new ingredient
                          _entry = _entry.rebuild((b) => b
                            ..meal.ingredients = BuiltList<Ingredient>(
                                    _entry.meal.ingredients.map((i) =>
                                        ingredient == i ? newIngredient : i))
                                .toBuilder());
                          diaryEntryBloc.dispatch(Update(_entry));
                        },
                      ),
                ),
              ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            deleteIngredient(ingredient);
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("${ingredient.food.name} removed.")),
            );
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      );
    }).toList();

    List<Widget> items = [
      DatetimeView(
        date: _entry.dateTime,
        onChanged: (dateTime) {
          _entry = _entry.rebuild((b) => b..dateTime = dateTime);
          diaryEntryBloc.dispatch(Update(_entry));
        },
      ),
      GutAICard(
        child: Column(
          children: [
            HeaderListTile(
              heading: 'Ingredients',
            )
          ]..addAll(ingredientTiles),
        ),
      ),
      NotesTile(
        notes: _entry.notes,
        onChanged: (notes) {
          _entry = _entry.rebuild((b) => b..notes = notes);
          diaryEntryBloc.dispatch(Update(_entry));
        },
      )
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Meal'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) =>
            Padding(padding: EdgeInsets.all(1.0), child: items[index]),
        padding: EdgeInsets.all(0.0),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IngredientEntryPage(
                      onSave: (newIngredient) => _entry = _entry.rebuild(
                          (b) => b..meal.ingredients.add(newIngredient)),
                    ),
              ),
            );
          }),
    );
  }
}
