import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'food-entry-page';

  final MealEntry entry;

  MealEntryPage({this.entry});

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.entry.meal.name),
      ),
      body: null
    );
  }
}
