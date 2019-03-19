import 'package:flutter/material.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';
import 'entry_header.dart';
import 'package:gut_ai/model/sensitivity.dart';
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
          ItemTileLarge(heading: "Banana", subheading:"1 each", sensitivity: Sensitivity.Minor,),
          ItemTileLarge(heading: "Egg", subheading: "2 each", sensitivity: Sensitivity.Major),
          BMEntryHeader(),
          ItemTileLarge(heading: "Moderate Consistency", subheading: "Moderate Volume"),
          MedicineEntryHeader(),
          ItemTileLarge(heading: "Fiber", subheading: "2 Tbsp"),
          ItemTileLarge(heading: "Pro-8", subheading: "1 each"),
        ],
      ),
    );
  }
}
