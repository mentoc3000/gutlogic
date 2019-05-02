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

  DiaryEntryListTile(
      {this.heading,
      this.subheadings,
      this.datetime,
      this.barColor,
      this.onTap});

  Widget buildTime() {
    var dateFormatter = DateFormat.jm();
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 6, 5, 0),
          child: Text(
            dateFormatter.format(datetime),
            textAlign: TextAlign.right,
          ),
        ),
        width: 80,
      ),
    );
  }

  Widget buildHeading() {
    return Text(
      this.heading,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }

  Widget buildSubheading() {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subheadings
            .map((s) => Container(
                  padding: EdgeInsets.all(3.0),
                  child: Text(s),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCenter() {
    List<Widget> children;
    if (subheadings == null) {
      children = [
        buildHeading(),
      ];
    } else {
      children = [
        buildHeading(),
        buildSubheading(),
      ];
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 3.0, color: this.barColor),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              buildTime(),
              buildCenter(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class MealEntryListTile extends StatelessWidget {
  final MealEntry entry;
  final void Function(MealEntry) onUpdate;

  MealEntryListTile({this.entry, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Food & Drink',
      subheadings: entry.meal.ingredients.map((e) => e.food.name),
      datetime: entry.dateTime,
      barColor: Colors.blue,
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealEntryPage(entry: entry))),
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealEntryPage(
                    entry: entry,
                    onUpdate: onUpdate,
                  ),
            ),
          ),
    );
  }
}

class BowelMovementEntryListTile extends StatelessWidget {
  final BowelMovementEntry entry;

  BowelMovementEntryListTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Bowel Movement',
      datetime: entry.dateTime,
      barColor: Colors.purple,
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BMEntryPage(
                    entry: entry,
                  ),
            ),
          ),
    );
  }
}

class DosesEntryListTile extends StatelessWidget {
  final DosesEntry entry;

  DosesEntryListTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Medicine',
      subheadings: entry.doses.map((d) => d.medicine.name),
      datetime: entry.dateTime,
      barColor: Colors.orange,
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DosesEntryPage(
                    entry: entry,
                  ),
            ),
          ),
    );
  }
}

class SymptomEntryListTile extends StatelessWidget {
  final SymptomEntry entry;

  SymptomEntryListTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: entry.symptom.name(),
      // subheadings: ['Severity: ' + entry.symptom.severity.toString()],
      datetime: entry.dateTime,
      barColor: Colors.red,
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealEntryPage(entry: entry))),
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SymptomEntryPage(
                    entry: entry,
                  ),
            ),
          ),
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
        border: Border(right: BorderSide(width: 3.0, color: this.borderColor)),
      ),
      child: SizedBox(
        width: 70.0,
        height: 70.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(0, 0, 3, 0),
                child: Text(formatter.format(datetime)))
          ],
        ),
      ),
    );
  }
}
