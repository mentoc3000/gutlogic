import 'package:flutter/material.dart';
import 'diary_tiles.dart';
import 'entry_header.dart';
import 'package:gut_ai/model/sensitivity.dart';
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
          FoodAndDrinkTileLarge(entry: Dummy.foodAndDrinkEntries[0],),
          FoodAndDrinkTileLarge(entry: Dummy.foodAndDrinkEntries[1],),
          BMEntryHeader(),
          BowelMovementTile(entry: Dummy.bowelMovementEntries[0],),
          MedicineEntryHeader(),
          MedicineTile(entry: Dummy.medicineEntries[0],),
          MedicineTile(entry: Dummy.medicineEntries[1],),
        ],
      ),
    );
  }
}
