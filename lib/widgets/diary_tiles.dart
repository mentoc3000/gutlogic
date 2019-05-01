import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'item_tile.dart';
import 'package:intl/intl.dart';
import '../pages/meal_entry_page.dart';
import '../pages/bm_entry_page.dart';
import '../pages/symptom_entry_page.dart';
import '../pages/medicine_entry_page.dart';

class MealEntryListTile extends StatelessWidget {
  final MealEntry entry;
  final void Function(MealEntry) onUpdate;

  MealEntryListTile({this.entry, this.onUpdate});
  
  @override
  Widget build(BuildContext context) {
    return GutAIListTile (
      heading: entry.meal.name,
      subheading: entry.meal.ingredients.map((e) => e.food.name).join(', '),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.blue,),
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealEntryPage(entry: entry))),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => MealEntryPage(entry: entry, onUpdate: onUpdate,)
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

class DosesEntryListTile extends StatelessWidget {
  final DosesEntry entry;

  DosesEntryListTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile (
      heading: 'Medicine', 
      subheading: entry.doses.map((d) => d.medicine.name).join(', '),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.orange,),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => DosesEntryPage(entry: entry,)
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