import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';

class FoodEntryPage extends StatefulWidget {
  static String tag = 'food-entry-page';

  final FoodAndDrinkEntry entry;

  FoodEntryPage({this.entry});

  @override
  FoodEntryPageState createState() => FoodEntryPageState();
}

class FoodEntryPageState extends State<FoodEntryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.entry.food.name),
      ),
      body: null
    );
  }
}
