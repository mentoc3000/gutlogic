import 'package:flutter/material.dart';
import 'diary_tiles.dart';
import 'entry_header.dart';
import 'package:gut_ai/models/sensitivity.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/resources/dummy_data.dart';

class DiaryPage extends StatefulWidget {
  static String tag = 'diary-page';
  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {

  List<Widget> entryTiles = [
    MealEntryListTile(entry: Dummy.mealEntries[0],),
    BowelMovementEntryListTile(entry: Dummy.bowelMovementEntries[0],),
    MedicineEntryListTile(entry: Dummy.medicineEntries[0],),
    MedicineEntryListTile(entry: Dummy.medicineEntries[1],),
    SymptomEntryListTile(entry: Dummy.symptomEntries[0],)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: entryTiles.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(1.0),
          child: entryTiles[index],
        ),
        padding: EdgeInsets.all(0.0),
      ),
    );
  }
}
