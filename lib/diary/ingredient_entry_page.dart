import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/model/ingredient.dart';
import 'quantity_view.dart';

class IngredientEntryPage extends StatefulWidget {
  static String tag = 'ingredient-entry-page';

  final MealEntry mealEntry;
  final Ingredient ingredient;

  IngredientEntryPage({this.ingredient, this.mealEntry});

  @override
  IngredientEntryPageState createState() => IngredientEntryPageState();
}

class IngredientEntryPageState extends State<IngredientEntryPage> {

  Ingredient _ingredient;
  List<Widget> items;

  @override
  void initState() {
    super.initState();
    _ingredient = widget.ingredient;

    this.items = [
      QuantityView(quantity: _ingredient.quantity,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Ingredient'),
      ),
      body: Form(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.all(1.0),
            child: items[index]
          ),
          padding: EdgeInsets.all(0.0),
        ),
      )
    );
  }
}
