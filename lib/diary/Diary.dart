import 'package:flutter/material.dart';
import 'package:gi_bliss/genericViews/ItemTileLarge.dart';
import 'EntryHeader.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:gi_bliss/model/DiaryEntry.dart';
import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/helpers/Dummy.dart';

class Diary extends StatefulWidget {
  static String tag = 'diary-page';
  @override
  DiaryState createState() => DiaryState();
}

class DiaryState extends State<Diary> {

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
