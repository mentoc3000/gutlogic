import 'package:flutter/material.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'placeholder_widget.dart';
import 'item_tile.dart';
import 'ingredient_entry_page.dart';
import 'datetime_view.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'gutai_card.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'meal-entry-page';

  final MealEntry entry;

  MealEntryPage({this.entry});

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {

  List<Widget> items;

  void addIngredient(Ingredient ingredient) {
    return setState(() {
      widget.entry.meal.ingredients.add(ingredient);
    });
  }

  void updateIngredient(Ingredient oldIngredient, Ingredient newIngredient) {
    return setState(() {
      int idx = widget.entry.meal.ingredients.indexOf(oldIngredient);
      widget.entry.meal.ingredients.replaceRange(idx, idx, [newIngredient]);
    });
  }

  void deleteIngredient(Ingredient ingredient) {
    return setState(() {
      widget.entry.meal.ingredients.remove(ingredient);
    });
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

    this.items = [
      DatetimeView(date: widget.entry.dateTime),
      GutAICard(
        child: Column(
          children: [HeaderListTile(
            heading: 'Ingredients',
          )]..addAll(
            widget.entry.meal.ingredients.map((i) => IngredientTile(
              ingredient: i, 
              mealEntry: widget.entry, 
              onTap:() => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => IngredientEntryPage(ingredient: i, onSaved: (n) => updateIngredient(i, n))))
              )
            )
          )
        )
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.entry.meal.name),
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
