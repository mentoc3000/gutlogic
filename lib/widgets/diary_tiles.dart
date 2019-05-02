import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'package:intl/intl.dart';
import '../pages/meal_entry_page.dart';
import '../pages/bm_entry_page.dart';
import '../pages/symptom_entry_page.dart';
import '../pages/medicine_entry_page.dart';

class DiaryEntryListTile extends StatelessWidget {
  final String heading;
  final Iterable<String> subheadings;
  final DateTime datetime;
  final Color barColor;
  final Function onTap;

  static TextStyle headingStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold
  );

  DiaryEntryListTile({this.heading, this.subheadings, this.datetime, this.barColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormat.jm();
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
            child:SizedBox(
              width: 80.0,
              // height: 70.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 3, 0),
                    child: Text(dateFormatter.format(datetime))
                  )
                ],
              )
            )
          ),
          Expanded(
            child:Container(
              padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 3.0, color: this.barColor)
                )
              ),
              child: Text(this.heading, style: headingStyle,),
            )
          ),
          Icon(Icons.keyboard_arrow_right)
        ],
      ),
    );
  }
}

class MealEntryListTile extends StatelessWidget {
  final MealEntry entry;
  final void Function(MealEntry) onUpdate;

  MealEntryListTile({this.entry, this.onUpdate});
  
  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile (
      heading: entry.meal.name,
      subheadings: entry.meal.ingredients.map((e) => e.food.name),
      datetime: entry.dateTime, 
      barColor: Colors.blue,
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
    return DiaryEntryListTile (
      heading: 'Type ' + entry.bowelMovement.type.toString(), 
      subheadings: ['Volume: ' + entry.bowelMovement.volume.toString()],
      datetime: entry.dateTime, 
      barColor: Colors.purple,
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
    return DiaryEntryListTile (
      heading: 'Medicine', 
      subheadings: entry.doses.map((d) => d.medicine.name),
      datetime: entry.dateTime, 
      barColor: Colors.orange,
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
    return DiaryEntryListTile (
      heading: entry.symptom.name(),
      subheadings: ['Severity: ' + entry.symptom.severity.toString()],
      datetime: entry.dateTime, 
      barColor: Colors.red,
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