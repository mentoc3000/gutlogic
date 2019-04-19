import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/model/ingredient.dart';
import 'quantity_view.dart';

class IngredientEntryPage extends StatefulWidget {
  static String tag = 'ingredient-entry-page';

  final Function onSaved;
  final Ingredient ingredient;

  IngredientEntryPage({this.ingredient, this.onSaved});

  @override
  IngredientEntryPageState createState() => IngredientEntryPageState();
}

class IngredientEntryPageState extends State<IngredientEntryPage> {

  Ingredient _ingredient;

  @override
  void initState() {
    super.initState();
    _ingredient = Ingredient.copy(widget.ingredient);
  }

  List<Widget> buildItems() {
    return [
      QuantityView(quantity: _ingredient.quantity,),
    ];
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> items = buildItems();    

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_ingredient?.food?.name ?? 'Ingredient'),
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
