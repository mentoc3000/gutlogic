import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/helpers/placeholder_widget.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';
import 'datetime_view.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'meal-entry-page';

  final MealEntry entry;

  MealEntryPage({this.entry});

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {

  List<Widget> items;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.items = <List<Widget>>[
        [
          DatetimeView(),
          GutAIListTile(heading: 'Ingredients', adder: true,)
        ],
        widget.entry.meal.ingredients.map((i) => GutAIListTile(heading: i.food.name)).toList()
      ].expand((x) => x).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.entry.meal.name),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(1.0),
          child: items[index]
        ),
        padding: EdgeInsets.all(0.0),
      ),
    );
  }
}
