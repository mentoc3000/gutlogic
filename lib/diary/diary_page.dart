import 'package:flutter/material.dart';
import 'package:gut_ai/generic_widgets/item_tile_large.dart';
import 'entry_header.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/model/food.dart';
import 'package:gut_ai/helpers/dummy_data.dart';

class DiaryPage extends StatefulWidget {
  static String tag = 'diary-page';
  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
      ),
      body: ListView(
        children: <Widget>[
          FoodEntryHeader(),
          ItemTileLarge("Banana", "1 each"),
          ItemTileLarge("Egg", "2 each"),
          BMEntryHeader(),
          ItemTileLarge("Moderate Consistency", "Moderate Volume"),
          MedicineEntryHeader(),
          ItemTileLarge("Fiber", "2 Tbsp"),
          ItemTileLarge("Pro-8", "1 each"),
        ],
      ),
    );
  }
}
