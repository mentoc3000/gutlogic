import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:gi_bliss/model/DiaryEntry.dart';
import 'package:gi_bliss/model/Food.dart';

class Diary extends StatefulWidget {
  @override
  DiaryState createState() => DiaryState();
}

class DiaryState extends State<Diary> {

  List<FoodAndDrinkEntry> foodAndDrinkEntries = [
    FoodAndDrinkEntry(
      dateTime: DateTime(2019, 2, 7, 8, 14), 
      food: Food(name: "Bread", irritants: ['Fructans']),
      quantity: "1 slice"
    ),
    FoodAndDrinkEntry(
      dateTime: DateTime(2019, 2, 7, 8, 14), 
      food: Food(name: "Egg", irritants: []),
      quantity: "1 each"
    )
  ];

  List<BowelMovementEntry> bowelMovementEntries = [
    BowelMovementEntry(
      dateTime: DateTime(2019, 2, 7, 11, 31),
      consistency: 4,
      volume: 2
    )
  ];

  List<MedicineEntry> medicineEntries = [
    MedicineEntry(
      dateTime: DateTime(2019, 2, 7, 12, 0),
      medicine: "Pro-8",
      dose: "1 pill"
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: Calendar(isExpandable: false,)
        ),
      ),
      body: ListView(
        children: <Widget>[],
      ),
    );
  }
}

