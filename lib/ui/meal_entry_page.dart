import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'item_tile.dart';
import 'ingredient_entry_page.dart';
import 'datetime_view.dart';
import '../models/ingredient.dart';
import 'gutai_card.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'meal-entry-page';

  final MealEntry entry;
  final void Function(MealEntry) onUpdate;

  MealEntryPage({this.entry, this.onUpdate});

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {

  MealEntry _entry;

  void addIngredient(Ingredient ingredient) {
    setState(() {
      _entry.meal.ingredients.add(ingredient);
    });
    widget.onUpdate(_entry);
  }

  void updateIngredient(Ingredient oldIngredient, Ingredient newIngredient) {
    setState(() {
      int idx = _entry.meal.ingredients.indexOf(oldIngredient);
      _entry.meal.ingredients.replaceRange(idx, idx, [newIngredient]);
    });
    widget.onUpdate(_entry);
  }

  void deleteIngredient(Ingredient ingredient) {
    setState(() {
      _entry.meal.ingredients.remove(ingredient);
    });
    widget.onUpdate(_entry);
  }

  void newIngredient() {
    Ingredient newIngredient = Ingredient();
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => IngredientEntryPage(ingredient: newIngredient, onSaved: addIngredient)
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> items = [
      DatetimeView(date: _entry.dateTime),
      GutAICard(
        child: Column(
          children: [HeaderListTile(
            heading: 'Ingredients',
          )]..addAll(
            _entry.meal.ingredients.map((i) => Dismissible(
              key: ObjectKey(i),
              child: IngredientTile(
                ingredient: i, 
                mealEntry: _entry, 
                onTap:() => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => IngredientEntryPage(ingredient: i, onSaved: (n) => updateIngredient(i, n)))
                )
              ),
              onDismissed: (direction) {
                if (direction ==DismissDirection.endToStart) {
                  deleteIngredient(i);
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("${i.food.name} removed.")));
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
              )
            ))
          )
        )
      )
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_entry.meal.name),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(1.0),
          child: items[index]
        ),
        padding: EdgeInsets.all(0.0),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: newIngredient
      ),
    );
  }
}
