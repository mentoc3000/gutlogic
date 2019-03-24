import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';
import 'package:intl/intl.dart';
import 'meal_entry_page.dart';
import 'bm_entry_page.dart';
import 'symptom_entry_page.dart';
import 'medicine_entry_page.dart';

class MealEntryListTile extends StatelessWidget {
  final MealEntry entry;

  MealEntryListTile({this.entry});
  
  @override
  Widget build(BuildContext context) {
    return GutAIListTile (
      heading: entry.meal.name,
      subheading: entry.meal.ingredients.map((e) => e.food.name).join(', '),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.blue,),
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealEntryPage(entry: entry))),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => MealEntryPage(entry: entry,)
      )),
    );
  }

}

class BowelMovementEntryListTile extends StatelessWidget {
  final BowelMovementEntry entry;

  BowelMovementEntryListTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile (
      heading: 'Type ' + entry.bowelMovement.type.toString(), 
      subheading: 'Volume: ' + entry.bowelMovement.volume.toString(),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.purple,),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => BMEntryPage(entry: entry,)
      )),
    );
  }

}

class MedicineEntryListTile extends StatelessWidget {
  final MedicineEntry entry;

  MedicineEntryListTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile (
      heading: entry.medicine.name, 
      subheading: entry.dose,
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.orange,),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => MedicineEntryPage(entry: entry,)
      )),
    );
  }

}

class SymptomEntryListTile extends StatelessWidget {
  final SymptomEntry entry;

  SymptomEntryListTile({this.entry});
  
  @override
  Widget build(BuildContext context) {
    return GutAIListTile (
      heading: entry.symptom.name(),
      subheading: 'Severity: ' + entry.symptom.severity.toString(),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.red,),
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealEntryPage(entry: entry))),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => SymptomEntryPage(entry: entry,)
      )),
    );
  }

}

class TimeLeader extends StatelessWidget {
  final DateTime datetime;
  final Color borderColor;

  TimeLeader({this.datetime, this.borderColor});

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat.jm();
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 3.0, color: this.borderColor)
        )
      ),
      child: SizedBox(
        width: 70.0,
        height: 70.0,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 3, 0),
              child: Text(formatter.format(datetime))
            )
          ],
        )
      )
    );
  }
}